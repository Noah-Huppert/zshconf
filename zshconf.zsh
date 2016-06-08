ZSHCONF_DIR=${ZSHCONF_DIR:=$HOME/.config/zshconf}
ZSHCONF_REPO_DIR=${ZSHCONF_REPO_DIR:=$ZSHCONF_DIR/repositories}
ZSHCONF_FILE=${ZSHCONF_FILE:=$ZSHCONF_DIR/zshconf}
ZSHCONF_REPO_UPDATE_INTERVAL=${ZSHCONF_REPO_UPDATE_INTERVAL:=86400} # Default is 1 day
ZSHCONF_SELF_UPDATE_INTERVAL=${ZSHCONF_SELF_UPDATE_INTERVAL:=86400} # Default is 1 day

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

function check_interval() { # (identifier, interval)
	interval_id=$1
	interval_timeout=$2

	interval_file="$ZSHCONF_DIR/intervals/$interval_id"

	current_time=$(date +%s)

	if [[ -a $interval_file ]]; then
		last_interval_time=$(cat $interval_file)
	else
		last_interval_time=0
		mkdir -p "$ZSHCONF_DIR/intervals"
		touch $interval_file
		echo $last_interval_time > $interval_file
	fi

	if (( $current_time - $last_interval_time >= $interval_timeout )); then
		echo $current_time > $interval_file
		true
	else
		false 
	fi
}

if ! type git > /dev/null; then
	llog $LOG_ERROR "Git not installed: Exiting"
	exit 1
fi

# Update zshconf
if check_interval "self_update" $ZSHCONF_SELF_UPDATE_INTERVAL ; then
	llog $LOG_INFO "Updating zshconf (self)"

	o=`git -C "$ZSHCONF_DIR" fetch --all 2>&1` || llog $LOG_ERROR $o
	o=`git -C "$ZSHCONF_DIR" reset --hard origin/master 2>&1` || llog $LOG_ERROR $o
fi


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
					# Check if time elapsed is greater than update interval
					if check_interval "repo_${repo_dir}_update" $ZSHCONF_REPO_UPDATE_INTERVAL ; then
						llog $LOG_INFO "    Updating"
						o=`git -C "$ZSHCONF_REPO_DIR/$repo_dir" fetch --all 2>&1` || llog $LOG_ERROR $o
						o=`git -C "$ZSHCONF_REPO_DIR/$repo_dir" reset --hard origin/master 2>&1` || llog $LOG_ERROR $o
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
