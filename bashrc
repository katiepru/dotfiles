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

#Russ PS1
#PS1="\n$TIMECOL\@ $USERCOL \u $ATCOL@ $HOSTCOL\h $PATHCOL \w $RETURNCOL\`nonzero_return\`$BRANCHCOL \`parse_git_branch\`\`parse_git_dirty\` $NC\n\\$ "
#PS1="[\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]] \`parse_git_branch\`\`parse_git_dirty\` \$ \[\033[01;31m\]❤ \[\e[m\]"
#export PS1="[\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]] \`parse_git_branch\`\`parse_git_dirty\` \$ \[\033[01;31m\]\`nonzero_return\` \[\e[m\]"
export PS1="[\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]] \`parse_git_branch\`\`parse_git_dirty\` \$ \[\033[01;31m\]\`nonzero_return\` \[\e[m\]"



#sync dotfiles
(
	cd ~/dotfiles
	git pull -q
	exit
)& disown


#program shortcuts
alias bashmod="vim ~/.bashrc"
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

#aliases for roundcube things
alias confdir="pushd ~/public_html/roundcube/branches/roundcubemail/ocnfig/"
alias olddir="pushd ~/public_html/roundcube/branches/0.4/src/"
alias branchdir="pushd ~/public_html/roundcube/branches/"

#ssh aliases
alias facade="ssh facade.rutgers.edu"
alias ziti="ssh ziti.rutgers.edu"
alias ravioli="ssh ravioli.rutgers.edu"
alias sauron="ssh sauron.rutgers.edu"
