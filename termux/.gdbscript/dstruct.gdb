
define plink
	if $argc < 3
		help plink
	else
		set $size = 0
		if $argc == 3
			set $start_cur = ($arg1*)($arg0)
		else
			if $arg3 == 0
				printf "666\n"
				set $start_cur = ($arg1*)($arg0)
			else
				set $start_cur = (struct $arg1*)($arg0)
			end
		printf "---------------------------\n"
		end
		while $start_cur != 0
			p/x *$start_cur
			set $size++
			set $start_cur = $start_cur->$arg2
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
			x/16bx $arg0
		else
			x/$arg1bx $arg0
		end
	end
end
document pmemory
	Example: pmemory pointer size
end

