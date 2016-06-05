ZSHCONF_DIR=${ZSHCONF_DIR:=$HOME/.config/zshconf}
ZSHCONF_REPO_DIR=${ZSHCONF_REPO_DIR:=$ZSHCONF_DIR/repositories}
ZSHCONF_FILE=${ZSHCONF_FILE:=$ZSHCONF_DIR/zshconf}
ZSHCONF_UPDATE_INTERVAL=${ZSHCONF_UPDATE_INTERVAL:=86400} # Default is 1 day
ZSHCONF_LASTUP_FILE="$ZSHCONF_DIR/last_update_time"

LOG_ERROR=0
LOG_INFO=1
LOG_BLANK_TAG="       "

function llog() {
	case $1 in
		$LOG_ERROR)
			log_prefix="[ERROR]"
			log_color=1
			;;
		$LOG_INFO)
			log_prefix="[INFO ]"
			log_color=4
			;;
		*)
			log_prefix="[MISC ]"
			log_color=5
			;;
	esac

	tput setaf $log_color

	echo "$log_prefix $2"

	tput sgr0
}

# Check if zshconf file exists
if [[ -a $ZSHCONF_FILE ]]; then
	# Loop through zshconf file by line
	line_num=1
	while read line; do
		# Ensures line doesn't contain a "#", if so ignored (Primitive comment system)
		if [[ ! $line =~ "#" ]]; then 
			# Check if line is a git repository uri
			if [[ $line =~ "[^#]+\.git" ]]; then
				repo_dir=$(echo $line | grep -Po "([^\/]+)\.git")
				repo_dir=${repo_dir%\.git}

				llog $LOG_INFO "repository \"$repo_dir\""

				# Update if git repo exists, clone if doesn't
				if [[ -d "$ZSHCONF_REPO_DIR/$repo_dir" ]]; then
					# Check for last update time
					current_time=$(date +%s)
					if [[ -a $ZSHCONF_LASTUP_FILE ]]; then
						last_update_time=$(cat $ZSHCONF_LASTUP_FILE)
					else
						last_update_time=0
						echo $last_update_time > $ZSHCONF_LASTUP_FILE
					fi

					# Check if time elapsed is greater than update interval
					if (( $current_time - $last_update_time >= $ZSHCONF_UPDATE_INTERVAL )); then
						llog $LOG_INFO "    Updating"
						o=`git -C "$ZSHCONF_REPO_DIR/$repo_dir" fetch --all 2>&1` || echo $o
						o=`git -C "$ZSHCONF_REPO_DIR/$repo_dir" reset --hard origin/master 2>&1` || echo $o

						echo $current_time > $ZSHCONF_LASTUP_FILE
					fi
				else
					git clone $line "$ZSHCONF_REPO_DIR/$repo_dir"
				fi
			# Else assume line is a file that should be loaded
			else
				if [[ ! -z "$repo_dir" ]]; then
					llog $LOG_INFO "    loading \"$line\""
					source $ZSHCONF_REPO_DIR/$repo_dir/$line
				else
					llog $LOG_ERROR "Unexpected file path (Ignoring), expected git repository uri (line: $line_num)\n$LOG_BLANK_TAG Found: \"$line\""
					tput setaf 0
				fi
			fi
		fi
		((line_num++))
	done <$ZSHCONF_FILE
else
	llog $LOG_ERROR "No zshconf file found (Expected: $ZSHCONF_FILE)"
fi

if ! type git > /dev/null; then
	llog $LOG_ERROR "Git not installed: Exiting"
	exit 1
fi
