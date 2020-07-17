import os
if __name__ == '__main__':
    with open('config.ini') as f:
        res = [x.strip() for x in f.readlines()]
        WORK_AP = res[0]
        path = res[1]
        f.close()
    os.system('su -c cp {} ./wifi.txt'.format(path))
    os.system('su -c chmod 777 ./wifi.txt')
    f = open('wifi.txt', 'r');
    cur_date = None
    start_time = end_time = None
    for line in f.readlines():
        l = line.strip().split()
        if len(l) != 6:
                continue;
        if WORK_AP in l[-1]:
            if cur_date != l[0]:
                if cur_date is not None:
                    print('{}: {} - {}'.format(cur_date, start_time, end_time))
                cur_date = l[0]
                start_time = l[1]
                end_time = l[1]
            else:
                end_time = l[1]
    print('{}: {} - {}'.format(cur_date, start_time, end_time))
    f.close()
