from re import match, findall, sub
import os
import xml.etree.ElementTree as et

CORE_SPEC_FILENAME = 'Core_v5.2.xml'
CORE_OUT_FILENAME = CORE_SPEC_FILENAME+'.txt'
CONTROLLER_PAGE_RANGE = (1929, 2288)  # (2473, 2754)
CONTROLLER_PAGE_RANGE = (2473, 2754)  # (2473, 2754)
PAGE_TOP_LIMIT = 100
PAGE_BOTTON_LIMIT = 1180

# pdftohtml -q -p -c -i -noframes -xml   Core_v5.2.pdf


def process_file():
    filename = CORE_SPEC_FILENAME + '.tmp'
    fr = open(CORE_SPEC_FILENAME, 'rb')
    fw = open(filename, 'w', encoding='utf-8')
    for line in fr.readlines():
        wb = bytes([x for x in line if 0x20 <= x < 128 or x == 0x0d or x == 0x0a])
        wstr = wb.decode('utf-8')
        wstr = sub(r'<a href.*?a>', '', wstr)
        wstr = sub(r'<[a-zA-Z/]+>', '', wstr)
        fw.write(wstr)
    fw.close()
    fr.close()
    fr = open(filename, 'r', encoding='utf-8')
    fw = open(CORE_OUT_FILENAME, 'w', encoding='utf-8')
    for line in fr.readlines():
        if len(line) > 5 and (line[:5] == '<text' or line[:5] == '<page'):
            fw.write(line)
    fw.close()
    fr.close()
    os.remove(filename)


class Pos:
    def __init__(self, left, top, width=-1, height=-1):
        self.left = left
        self.top = top
        self.width = width
        self.height = height
    def __str__(self):
        return 'Pos({},{})'.format(self.left, self.top)

class Text:
    def __init__(self, text, pos):
        self.text = text
        self.pos = pos
    def __str__(self):
        return '{}'.format(self.text)

class ParsePage:
    def __init__(self, page):
        self.page = page
        self.text_list = []
    def add_text(self, text):
        self.text_list.append(text)
    def sort(self):
        self.text_list.sort(key=lambda item: (item.pos.top << 16) + item.pos.left)
    def dump(self):
        print('Page {}'.format(self.page))
        for text in self.text_list:
            print('{:4} {:4}  {}'.format(text.pos.left, text.pos.top, text.text))

class ParseEnv:
    RE_MARK_PAGE = r'^\<page number="[0-9]+'
    RE_MARK_TEXT = r'^\<text top="[0-9]+" left="[0-9]+" width="[0-9]+" height="[0-9]+" font="[0-9]+"\>.*?$'
    def __init__(self, filename, page_range=(0, 0xffffffff)):
        self.pages = []
        in_range = False
        start_page = page_range[0]
        end_page = page_range[1]
        file = open(filename, encoding='utf-8')
        lines = file.readlines()
        for line_num in range(len(lines)):
            line = lines[line_num]
            if match(ParseEnv.RE_MARK_PAGE, line):
                page_num = int(line.split('"')[1], 0)
                if in_range:
                    if page_num > end_page:
                        break
                    else:
                        self.pages.append(ParsePage(page_num))
                else:
                    if page_num >= start_page:
                        in_range = True
                        self.pages.append(ParsePage(page_num))
            elif in_range and match(ParseEnv.RE_MARK_TEXT, line):
                split_text = line.split('"')
                top = int(split_text[1], 0)
                left = int(split_text[3], 0)
                width = int(split_text[5], 0)
                height = int(split_text[7], 0)
                if PAGE_TOP_LIMIT < top < PAGE_BOTTON_LIMIT:
                    text = split_text[10][1:].strip() if len(split_text)>10 and len(split_text[10]) > 1 else ''
                    if len(text) > 0:
                        self.pages[-1].add_text(Text(text, Pos(left, top, width, height)))
        # sort text in page by top position
        for page in self.pages:
            page.sort()
        file.close()


class ParamDetail:
    def __init__(self, name=None):
        self.name = name
        self.size = []
        self.lines = []

class CommandRec:
    def __init__(self):
        self.page = -1
        self.name = ''
        self.title_pos = []  # [[pos, name], ...]
        self.items_text = [[]for _ in range(4)]  # [[Cmd str...],[OCF str...],[Param str...],[return str...]]
        self.items_text_sep = [[]for _ in range(4)]  # 还带换行的 items_text
        self.param_str_list = []
    def __str__(self):
        return '{} - {}'.format(self.page, self.name)


class ParseCommand:
    RE_MARK_CMD_LINE = r'^7\.[0-9]\.[0-9]+[ ]+[A-Z]'
    ST_IDLE = 0
    ST_PARSE_FMT = 1
    ST_PARSE_DESC = 2
    ST_PARSE_CMD_PARAM = 3
    ST_PARSE_RETURN = 4
    ST_PARSE_EVENT = 5
    def __init__(self, filename, page_range=(0, 0xffffffff)):
        self.env = ParseEnv(filename, page_range)
        self.cmds = []
        self.param_tmp = None
        state = ParseCommand.ST_IDLE
        page_idx = 0
        cmd_rec = None
        # format parse
        cmd_title_pos = []
        while page_idx < len(self.env.pages):
            text_idx = 0
            page = self.env.pages[page_idx]
            while text_idx < len(page.text_list):
                text = page.text_list[text_idx]
                if state == ParseCommand.ST_IDLE:
                    if findall(ParseCommand.RE_MARK_CMD_LINE, text.text):
                        cmd_rec = CommandRec()
                        cmd_rec.page = page.page
                        name_line_num = text_idx
                        while name_line_num < len(page.text_list):
                            cur_text = page.text_list[name_line_num]
                            if cur_text.pos.top == text.pos.top:
                                cmd_rec.name += cur_text.text
                                name_line_num += 1
                            else:
                                break
                        text_idx = name_line_num
                        state = ParseCommand.ST_PARSE_FMT
                        continue
                elif state == ParseCommand.ST_PARSE_FMT:
                    title_line_num = text_idx
                    while title_line_num < len(page.text_list) and len(cmd_rec.title_pos) < 4:
                        cur_text = page.text_list[title_line_num]
                        pos_idx = -1
                        for i in range(len(cmd_rec.title_pos)):
                            pos = cmd_rec.title_pos[i]
                            if cur_text.pos.left == pos[0]:
                                pos_idx = i
                                break
                        if pos_idx < 0:
                            cmd_rec.title_pos.append([cur_text.pos.left, cur_text.text])
                        else:
                            cmd_rec.title_pos[pos_idx][1] += ' ' + cur_text.text.strip()
                        title_line_num += 1
                        if len(cmd_rec.title_pos) == 4:
                            cmd_rec.title_pos.sort()  # 找到Command OCF Cmd_Param Return_Param的left坐标
                            if sum([1 if 'ommand' in x[1] else 0 for x in cmd_rec.title_pos]) >= 3:
                                #  Cmd的title太长导致换行，需要特殊判断换行后误认为行尾名称是Cmd format的title
                                cmd_rec.name += ' ' + cmd_rec.title_pos[0][1].strip()
                                del(cmd_rec.title_pos[0])
                    text_idx = title_line_num
                    # 查找未完成的title（title两个单词换行导致）
                    title_line_num = text_idx
                    while title_line_num < len(page.text_list) and \
                            (len(cmd_rec.title_pos[2][1].split()) < 2 or len(cmd_rec.title_pos[3][1].split()) < 2):
                        cur_text = page.text_list[title_line_num]
                        for i in (2, 3):
                            if cur_text.pos.left == cmd_rec.title_pos[i][0]:
                                cmd_rec.title_pos[i][1] += ' ' + cur_text.text.strip()
                        title_line_num += 1
                    text_idx = title_line_num
                    # cmd format的title已找到，放在cmd_rec.title_pos中，格式为[[pos0, cmd], [pos1, OCF], ...]
                    # 查找Cmd的format参数（cmd, ocf, param, return）
                    fmt_idx = text_idx
                    while fmt_idx < len(page.text_list):
                        cur_text = page.text_list[fmt_idx]
                        if 'Description' in cur_text.text:  # format 参数查找完成
                            # 合并已经换行的字符串
                            for i in range(4):
                                for j in range(len(cmd_rec.items_text_sep[i])):
                                    if len(cmd_rec.items_text[i]) == 0:
                                        cmd_rec.items_text[i].append(cmd_rec.items_text_sep[i][j])
                                        continue
                                    elif cmd_rec.items_text[i][-1].text[-1] == '-':  # Command 最后以'-''换行
                                        cmd_rec.items_text[i][-1].text = cmd_rec.items_text[i][-1].text[:-1] + cmd_rec.items_text_sep[i][j].text
                                    elif len(cmd_rec.items_text_sep[i][j].text) < 7 and cmd_rec.items_text[i][-1].text[-1] != ',':  # 特殊处理没有以'-'换行的换行
                                        cmd_rec.items_text[i][-1].text = cmd_rec.items_text[i][-1].text + cmd_rec.items_text_sep[i][j].text
                                    else:
                                        cmd_rec.items_text[i].append(cmd_rec.items_text_sep[i][j])
                            state = ParseCommand.ST_PARSE_DESC
                            break
                        for i in range(4):
                            if cur_text.pos.left == cmd_rec.title_pos[i][0]:
                                cmd_rec.items_text_sep[i].append(cur_text)
                        fmt_idx += 1
                    text_idx = fmt_idx
                elif state == ParseCommand.ST_PARSE_DESC:
                    idx = text_idx
                    while idx < len(page.text_list):
                        cur_text = page.text_list[idx]
                        if 'Command parameters:' in cur_text.text or 'Parameters:' in cur_text.text:  # 找到参数开头的位置
                            state = ParseCommand.ST_PARSE_CMD_PARAM
                            break
                        idx += 1
                    text_idx = idx
                elif state == ParseCommand.ST_PARSE_CMD_PARAM:
                    idx = text_idx
                    while idx < len(page.text_list):
                        cur_text = page.text_list[idx]
                        if 'Return parameters:' in cur_text.text or 'None' in cur_text.text:  # 找到返回值开头的位置
                            if self.param_tmp is not None:
                                cmd_rec.param_str_list.append(self.param_tmp)
                                self.param_tmp = None
                            break
                        elif 'Event(s) generated' in cur_text.text or 'Events(s) generated' in cur_text.text:  # 找到事件开头的位置
                            if self.param_tmp is not None:
                                cmd_rec.param_str_list.append(self.param_tmp)
                                self.param_tmp = None
                            state = ParseCommand.ST_PARSE_EVENT
                            break

                        if findall(r'^[a-zA-Z_0-9\[\]]+:', cur_text.text) and idx+1 < len(page.text_list) and \
                                'Size:' in page.text_list[idx+1].text:
                            if self.param_tmp is not None:
                                cmd_rec.param_str_list.append(self.param_tmp)
                            self.param_tmp = ParamDetail(cur_text)
                            while idx < len(page.text_list):
                                if cur_text.pos.top == page.text_list[idx].pos.top:
                                    if cur_text.pos.left != page.text_list[idx].pos.left:
                                        self.param_tmp.size.append(page.text_list[idx])
                                    idx += 1
                                else:
                                    idx -= 1
                                    break
                        elif self.param_tmp is not None:
                            tmp_list = []
                            while idx < len(page.text_list):
                                if cur_text.pos.top == page.text_list[idx].pos.top:
                                    tmp_list.append(page.text_list[idx])
                                    idx += 1
                                else:
                                    idx -= 1
                                    break
                            self.param_tmp.lines.append(tmp_list)
                        idx += 1
                    text_idx = idx
                elif state == ParseCommand.ST_PARSE_EVENT:
                    idx = text_idx
                    while idx < len(page.text_list):
                        cur_text = page.text_list[idx]
                        if True:
                            self.cmds.append(cmd_rec)
                            state = ParseCommand.ST_IDLE
                            break
                        idx += 1
                    text_idx = idx
                else:
                    pass
                text_idx += 1
            page_idx += 1


# process_file()
pcmd = ParseCommand(CORE_OUT_FILENAME, CONTROLLER_PAGE_RANGE)

for cmd in pcmd.cmds:
    for param in cmd.param_str_list:
        print(param.name, param.size[0])
        for line in param.lines:
            print('\t\t', end='')
            if line[0].pos.left > param.lines[0][0].pos.left:
                print('', end=' '*19)
            for l in line:
                print(' | {:16s}'.format(l.text), end='')
            print(' |')
