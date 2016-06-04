ZSHCONF_FILE=${ZSHCONF_FILE:=$HOME/.config/zshconf/zshconf}

if [[ -a $ZSHCONF_FILE ]]; then
	line_num=0
	while read line; do
		if [[ ! $line =~ "#" ]]; then 
			if [[ $line =~ "[^#]+\.git" ]]; then
				echo "Repo => $line"
				repo_dir=$(echo $line | grep -Po "([^\/]+)\.git")
				repo_dir=${repo_dir%\.git}
			else
				if [[ ! -z "$repo_dir" ]]; then
					echo "File => { repo_dir: $repo_dir, line: $line }"
				else
					echo "[ERROR] Unexpected file path (Ignoring), expected git repository uri (line: $line_num)"
				fi
			fi
		fi
		((line_num++))
	done <$ZSHCONF_FILE
else
	echo "No zshconf file found (Expected: $ZSHCONF_FILE)"
fi

if ! type git > /dev/null; then
	echo "Git not installed: Exiting"
	exit 1
fi
