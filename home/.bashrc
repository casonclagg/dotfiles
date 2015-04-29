os=`uname`

if [[ "$os" == 'Linux' ]]; then
  JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:bin/javac::")
  alias ls='ls --color=auto'
elif [[ "$os" == 'Darwin' ]]; then
  JAVA_HOME=`/usr/libexec/java_home -v1.7`
  alias ls='ls -G'
fi

# run local bash stuff (pc-specific aliases and such)
if [ -f ~/.bash_local ]; then
    . ~/.bash_local
fi

export GOPATH=$HOME/dev/go
PATH=/usr/local/go/bin:$PATH
PATH=$JAVA_HOME/bin:$PATH
PATH=$HOME/bin:$PATH
PATH=$JAVA_HOME/bin:$PATH
PATH=$PATH:$HOME/bin
PATH=$PATH:$GOPATH/bin

# common aliases 
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias st='git status'
alias hs='homesick'
alias hsgit='cd ~/.homesick/repos/dotfiles'

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

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
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

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

source ~/.git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWCOLORHINTS=1
PROMPT_DIRTRIM=5
PROMPT_COMMAND='__git_ps1 "\[\e[01;34m\]\w\[\e[0m\]" "\n\h\$ "'

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
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
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

# push public key to remote servers
function ssh-pushkey {
  ssh $1 "echo '`cat ~/.ssh/id_rsa.pub`' >> ~/.ssh/authorized_keys"
}

# add something to gitignore
function gi {
  echo "$1" >> .gitignore
}

# grab the ip of a docker contanier by name
function dockerip {
  sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1
}

# ssh to a docker container by name using the insecure key
function scraw {
  ssh scraw@$(dockerip $1) -i ~/.ssh/docker_insecure_key
}

function scraw-push-ssh {
  scp -i ~/.ssh/docker_insecure_key $2 scraw@$(dockerip $1):~/.ssh/id_rsa
}

function docker-clean {
  docker rm $(docker ps -a -q)
  docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
}
