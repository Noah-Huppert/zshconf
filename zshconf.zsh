ZSHCONF_FILE=${ZSHCONF_FILE:=$HOME/.config/zshconf/zshconf}

if [[ -a $ZSHCONF_FILE ]]; then
	cat $ZSHCONF_FILE
else
	echo "No zshconf file found (Expected: $ZSHCONF_FILE)"
fi

if ! type git > /dev/null; then
	echo "Git not installed: Exiting"
	exit 1
fi
