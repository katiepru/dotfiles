#export statements
export EDITOR=vim
export TERM='xterm-256color'
export PATH="$PATH:/sbin"

parse_git_branch() {
	TMPRET=$?
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
	return $TMPRET
}

function parse_git_dirty {
	TMPRET=$?
	status=`git status 2> /dev/null`
	dirty=`echo -n "${status}" 2> /dev/null | grep -q "modified:" 2> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep -q "Untracked files" 2> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep -q "Your branch is ahead of" 2> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep -q "new file:" 2> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep -q "renamed:" 2> /dev/null; echo "$?"`
	bits=''
	if [ "${dirty}" == "0" ]; then
		bits="${bits}⚡"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="${bits}?"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="${bits}+"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="${bits}*"
	fi
	if [ "${renamed}" == "0" ]; then
		bits="${bits}>"
	fi
	echo "${bits}"
	return $TMPRET
}

nonzero_return() {
	RETVAL=$?
	if [ $RETVAL -ne 0 ]
	then
		echo "⏎$RETVAL"
	else
		echo "❤"
	fi
}

ISROOT=""

function isroot() {
	if id | cut -d' ' -f1 | grep -iq 'root'; then
		ISROOT=true
	else
		ISROOT=false
	fi
}
isroot

function user_col() {
	if [ "$ISROOT" == "true" ]; then
		echo -ne "\033[38;5;1;01m"
	else
		echo -ne "\033[01;32m"
	fi
}

#Russ PS1
#PS1="\n$TIMECOL\@ $USERCOL \u $ATCOL@ $HOSTCOL\h $PATHCOL \w $RETURNCOL\`nonzero_return\`$BRANCHCOL \`parse_git_branch\`\`parse_git_dirty\` $NC\n\\$ "
#PS1="[\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]] \`parse_git_branch\`\`parse_git_dirty\` \$ \[\033[01;31m\]❤ \[\e[m\]"
#export PS1="[\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]] \`parse_git_branch\`\`parse_git_dirty\` \$ \[\033[01;31m\]\`nonzero_return\` \[\e[m\]"
#export PS1="[\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]] \`parse_git_branch\`\`parse_git_dirty\` \$ \[\033[01;31m\]\`nonzero_return\` \[\e[m\]"
export PS1="[\[`user_col`\]\u\[\033[00m\]\[\033[01;32m\]@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]] \`parse_git_branch\`\`parse_git_dirty\` \$ \[\033[01;31m\]\`nonzero_return\` \[\e[m\]"



#sync dotfiles
function syncdot() {
	pushd ~/dotfiles > /dev/null
	git pull -q
	popd > /dev/null
}

if [ "$ISROOT" == "false" ]; then
	syncdot
fi


if [ "`alias -p | grep bashmod`" != "" ]; then
	unalias bashmod
fi

function bashmod() {
	BASHDIR=`cat ~/.bashrc | head -n 1 | cut -d' ' -f2`
	LOCALDIR=`cat ~/.bashrc | sed -n '2p' | cut -d' ' -f2`
	DIR=""
	IFS='/'
	for word in $BASHDIR; do
		if [ "$word" != "bashrc" ] && [ "$word" != "" ]; then
			DIR="$DIR/$word"
		fi
	done
	IFS=" "
	if [ "$1" == "main" ]; then
		vim -c "set syn=sh" $BASHDIR
	elif [ "$1" == "local" ]; then
		if [ "$LOCALDIR" == "" ]; then
			echo -e "\e[01;31m There isn't a local bashrc \e[m"
			return 2
		else
			vim -c "set syn=sh" $LOCALDIR
		fi
	elif [ "$1" == "real" ]; then
		vim ~/.bashrc
	elif [ "$1" == "help" ]; then
		echo "Usage: bashmod main|local|real|help|<ext>"
	else
		if [ -f "$DIR/bashrc_$1" ]; then
			vim -c "set syn=sh" $DIR/bashrc_$1
		else
			echo -e "\e[01;31m Bashrc_$1 doesn't exist \e[m"
			return 2
		fi
	fi
}

function swapkey() {
	xmodmap -e 'keycode 66 = Caps_Lock' \
	-e 'keycode 9 = Escape' \
	-e 'remove Lock = Caps_Lock' \
	-e 'keycode 9 = Caps_Lock' \
	-e 'keycode 66 = Escape'
}

swapkey &> /dev/null

#program shortcuts
alias bashsave="source ~/.bashrc"
alias vmod="vim ~/.vimrc"
alias xmod="vim ~/.xinitrc"
alias lock="xscreensaver-command -lock"

#aliases for ls
alias ls="ls --color=always"
alias lsa="ls -a"
alias lsd="ls --color=always -alh | grep ^d"
alias lf="ls --color=always -lh | grep ^d"
alias l="ls"
alias s="l"
alias sl="ls"
alias la="ls -Alh"
alias ll="ls -lh"

#aliases for random ops
alias cc="clear"
alias sudo="sudo -E"

#aliases for directory navigation
alias ..="cd .."
alias vi="vim"
alias v="vim"
alias me="cd ~;ls"

#ssh aliases
alias facade="ssh facade.rutgers.edu"
alias ziti="ssh ziti.rutgers.edu"
alias ravioli="ssh ravioli.rutgers.edu"
alias sauron="ssh sauron.rutgers.edu"
