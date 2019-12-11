# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

if [ -t 1 ]; then
  exec zsh
fi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

####################################################################################################
############################################# Fancy Prompt #########################################
####################################################################################################
__git_status_info() {
    STATUS=$(git status 2>/dev/null |
    awk -v r=${RED} -v y=${YELLOW} -v g=${GREEN} -v b=${BLUE} -v n=${NC} '
    /^On branch / {printf(y$3n)}
    /^Changes not staged / {printf(g"|?Changes unstaged!"n)}
    /^Changes to be committed/ {printf(b"|*Uncommitted changes!"n)}
    /^Your branch is ahead of/ {printf(r"|^Push changes!"n)}
    ')
    if [ -n "${STATUS}" ]; then
        echo -ne " ${STATUS} ${LIGHTCYAN}[Last updated: $(git show -1 --stat | grep ^Date | cut -f4- -d' ')]${NC}"
    fi
}

__disk_space=$(/bin/df --output=pcent /home | tail -1)
_ip_add=$(ip addr | grep -w inet | gawk '{if (NR==2) {$0=$2; gsub(/\//," "); print $1;}}')
__ps1_startline="\[\033[0;32m\]\[\033[0m\033[0;38m\]\u\[\033[0;36m\]@\[\033[0;36m\]\h on ${_ip_add}:\w\[\033[0;32m\] \[\033[0;34m\] [disk:${__disk_space}] \[\033[0;32m\]"
__ps1_endline="\[\033[0;32m\]└─\[\033[0m\033[0;31m\] [\D{%F %T}] \$\[\033[0m\033[0;32m\] >>>\[\033[0m\] "
export PS1="${__ps1_startline}\$(__git_status_info)\n${__ps1_endline}"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export PATH="/home/tbulding/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PATH="/home/tbulding/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

####################################################################################################
############################################ Welcome Message #######################################
####################################################################################################
if [ -f /var/run/reboot-required ]; then
    echo "${REDBG}[*** Hello ${USER}, you must reboot your machine ***]${NC}\n";
fi

IP_ADD=`ip addr | grep -w inet | gawk '{if (NR==2) {$0=$2; gsub(/\//," "); print $1;}}'`
printf "${LIGHTGREEN}Hello, ${USER}@${IP_ADD}\n"
printf "Today is, $(date)\n";
printf "\nSysinfo: $(uptime)\n"
# if [ -f ~/.weather.log ]; then
#     while IFS='' read -r line || [[ -n "$line" ]]; do
#         printf "${LIGHTBLUE}%s\n${NC}" "${line}"
#     done < ~/.weather.log
# fi
printf "\n${YELLOW}Get a list of available functions: 'declare -F'\n"
#printf "${LIGHTCYAN}\n$(fortune | cowsay)${NC}\n"
