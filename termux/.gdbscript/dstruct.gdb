
define memset
    if $argc != 3
        help memset
    else
        set $st_addr = $arg0
        set $en_addr = $arg0+$arg2
        while($st_addr < $en_addr)
            set *(unsigned char*)$st_addr = $arg1
            set $st_addr = $st_addr + 1
        end
    end
end
document memset
    Example: memset s c n
end

define memark
    if $argc != 2
        help memark
    else
        set $st_addr = $arg0 & (~0x3)
        set $en_addr = $arg0+$arg1
        while($st_addr < $en_addr)
            set *(unsigned int*)$st_addr = $st_addr
            set $st_addr = $st_addr + 4
        end
    end
end
document memark
    Example: memark s n
end

define plink
    if $argc < 3
        help plink
    else
        set $size = 0
        if $argc == 3
            set $start_cur = ($arg1*)($arg0)
        else
            if $arg3 == 0
                set $start_cur = ($arg1*)($arg0)
            else
                set $start_cur = (struct $arg1*)($arg0)
            end
        printf "---------------------------\n"
        end
        while $start_cur != 0
            set $size++
            if $arg3 == 0
                p/x *($arg1*)$start_cur
                set $start_cur = (($arg1*)$start_cur)->$arg2
            else
                p/x *(struct $arg1*)$start_cur
                set $start_cur = ((struct $arg1*)$start_cur)->$arg2
            end
        end
        printf "link size = %u\n", $size
    end
end
document plink
    Example: plink headAddr struct_type struct_next if_struct_define
end

define pmemory
    if $argc < 1
        help pmemory
    else
        if $argc == 1
            x/16bx (uint8_t*)$arg0
        else
            x/$arg1bx (uint8_t*)$arg0
        end
    end
end
document pmemory
    Example: pmemory pointer size
end

define sp_symbol_dump
    set $dump_num=16
    set $pc_backup = $pc
    set $lr_backup = $lr
    set $sp_backup = $sp
    printf "$sp=0x%08x\n", $sp
    if $argc > 0
        set $dump_num=$arg0
    end
    set $i=0
    while($i<$dump_num)
        set $symbol_addr = *(unsigned int*)($i * 4 + $sp)
        printf "0x%08x -> ", $symbol_addr
        info symbol $symbol_addr
        set $i = $i + 1
    end
end
document sp_symbol_dump
    Example: dump_sp_symbol [number]
end

define try_bt
       if $argc != 1
        help try_bt
    else
        printf "$sp=0x%08x\n", $sp
        set $pc = $arg0
        bt
        set $sp = $sp + 4
    end
end
document try_bt
    Example: try_bt $pc_addr
end

