#!/usr/bin/env bash
pushd ~/ > /dev/null

if [ -f .bashrc ] || [ -h .bashrc ]
then
	rm .bashrc
fi
if [ -f .bash_profile ] || [ -h .bash_profile ]
then
	rm .bash_profile
fi
if [ -f .gitconfig ] || [ -h .gitconfig ]
then
	rm .gitconfig
fi
if [ -f .vimrc ] || [ -h .vimrc ]
then
	rm .vimrc
fi
if [ -f .tmux.conf ] || [ -h .tmux.conf ]
then
	rm .tmux.conf
fi

pushd dotfiles/ > /dev/null

f="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -z "$f" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

unlink ~/.bashrc &> /dev/null
unlink ~/.zshrc &> /dev/null
echo "Adding main bashrc and zshrc"
echo "source $f/bashrc" > ~/.bashrc
echo "source $f/zshrc" > ~/.zshrc
if [ "$1" != "" ]
then
	if [ -f $f/bashrc_$1 ]
	then
		echo "Adding bashrc_$1"
		echo "source $f/bashrc_$1" >> ~/.bashrc
	else
		echo "bashrc_$1 does not exist"
		exit 2
	fi
	if [ -f $f/zshrc_$1 ]
	then
		echo "Adding zshrc_$1"
		echo "source $f/zshrc_$1" >> ~/.zshrc
	else
		echo "zshrc_$1 does not exist"
		exit 2
	fi
fi
ln -s ~/.bashrc ~/.bash_profile
source ~/.bashrc

if test -h ~/.ssh/config
then
	unlink ~/.ssh/config &> /dev/null
fi
if ! [ -f ~/.ssh/config ]
then
	echo "Installing ssh config"
	cp $f/ssh_config ~/.ssh/config
fi

IGNORE="bashrc|zshrc|ssh|init|gitignore|README|.gitmodules"

for file in $(git ls-files | egrep -v $IGNORE)
do
	echo "Installing $file"
	if test ! -d `dirname ~/.$file`
	then
		mkdir -p `dirname ~/.$file`
	fi
	if test -h ~/.$file
	then
		unlink ~/.$file &> /dev/null
	fi
	ln -sf $f/$file ~/.$file
done

if ! [ -h .git/hooks/post-merge ]; then
	echo "Installing post-merge hook"
	hook=".git/hooks/post-merge"
	echo "#!/usr/bin/env bash" > $hook
	echo "cd $f" >> $hook
	echo "git submodule init && git submodule update" >> $hook
	#Should find a way to do this better
	if ! [ -z $1 ]; then
		echo "./init.sh $1" >> $hook
	else
		echo "./init.sh" >> $hook
	fi

	chmod 755 $hook

	echo "Initializing submodules"
	git submodule init && git submodule update
fi

popd > /dev/null
popd > /dev/null

exit 0
