#export PATH=/bin:$PATH

ln -sf /android_data /data

export PATH=$HOME/.shortcuts:$PATH
export PATH=$HOME/.bin:$PATH
export PATH=$HOME/.bin/platform-tools:$PATH
export PATH=$HOME/.bin/gcc-arm-none-eabi-9-2020-q2-update/bin:$PATH
export PATH=$PATH:/vendor/bin:/system/sbin:/system/bin
export LD_LIBRARY_PATH=/vendor/lib:/system/lib64:$LD_LIBRARY_PATH
export ANDROID_DATA=/data
export ANDROID_ROOT=/system

#for file in ~/../usr/etc/bash_completion.d/* ; do
#    source "$file"
#done
# source /etc/bash_completion.d/git-prompt

sysctl -w net.ipv6.conf.all.disable_ipv6=0 &> /dev/null
sysctl -w net.ipv6.conf.default.disable_ipv6=0 &> /dev/null

#python3 python3-pip clang cmake gcc curl wget net-tools openssl vim git iputils-ping ctags cscope splint astyle

export TERM=xterm-color
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

export COLOR_NC='\e[0m' # No Color
export COLOR_WHITE='\e[1;37m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_GRAY='\e[0;30m'
export COLOR_LIGHT_GRAY='\e[0;37m'
case $TERM in
     xterm*|rxvt*)
         TITLEBAR='\[\033]0;\u ${NEW_PWD}\007\]'
          ;;
     *)
         TITLEBAR=""
          ;;
    esac

UC=$COLOR_WHITE               # user's color
[ $UID -eq "0" ] && UC=$COLOR_RED   # root's color

#PS1="$TITLEBAR\n\[${UC}\]\u \[${COLOR_LIGHT_BLUE}\]\${PWD} \[${COLOR_BLACK}\]\$(vcprompt) \n\[${COLOR_LIGHT_GREEN}\]→\[${COLOR_NC}\] "
PS1="\[${COLOR_LIGHT_GREEN}\]→|\[${COLOR_NC}\]"

export LS_COLORS='rs=0:di=01;33:ln=01;36:mh=00:pi=40;33'
## Colorize the ls output ##
alias ls='ls --color=auto'
## Use a long listing format ##
alias ll='ls -la'
## Show hidden files ##
alias l.='ls -d .* --color=auto'
alias l='ls'
alias python='python3'
alias .='pwd'
alias ..='cd ..;pwd'
alias ...='cd ../..;pwd'
alias grep='grep --color=auto'
alias ctag='ctags -R -f .tags'

