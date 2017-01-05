# Default values, can be customized
# Directory zshconf will use to store files and look for config
ZSHCONF_DIR=${ZSHCONF_DIR:=$HOME/.config/zshconf}
# Directory used by zshconf to store persistant value files
ZSHCONF_PERSIST_DIR=${ZSHCONF_PERSIST_DIR:=$ZSHCONF_DIR/persist}
# Directory used by zshconf to clone repositories
ZSHCONF_REPO_DIR=${ZSHCONF_REPO_DIR:=$ZSHCONF_DIR/repositories}
# Path to zshconf configuration file
ZSHCONF_FILE=${ZSHCONF_FILE:=$ZSHCONF_DIR/zshconf}
# Default repo update interval time (15 days in seconds)
ZSHCONF_REPO_UPDATE_INTERVAL=${ZSHCONF_REPO_UPDATE_INTERVAL:=1296000}
# Default update interval for zshconf self update (15 days in seconds)
ZSHCONF_SELF_UPDATE_INTERVAL=${ZSHCONF_SELF_UPDATE_INTERVAL:=1296000}

# Log system constants
LOG_ERROR=0
LOG_INFO=1
LOG_UPDATE=2
LOG_BLANK_TAG="       "

# Print text in color of log level
function lcolor() { # (level, content)
	# Args
	level=$1
	content=$2

	# Set color based on level
	case $level in
		$LOG_ERROR)
			log_color=1
			;;
		$LOG_INFO)
			log_color=4
			;;
		$LOG_UPDATE)
			log_color=2
			;;
		*)
			log_color=5
			;;
	esac

	# Set color
	tput setaf $log_color

	# Output
	echo "$content"

	# End color block
	tput sgr0
}

# Log helper function which prints log level prefix and colors output
function llog() { # (level, content)
	# Args
	level=$1
	content=$2

	# Set log prefix and color based off of level
	case $level in
		$LOG_ERROR)
			log_prefix="[ERROR]"
			;;
		$LOG_INFO)
			log_prefix="[INFO ]"
			;;
		$LOG_UPDATE)
			log_prefix="[zshconf][Update] "
			;;
		*)
			log_prefix="[MISC ]"
			;;
	esac

	lcolor $level "$log_prefix $content"
}

# Present the user with a Y/n prompt using a certain log level
function ynprompt() { # (level, prompt)
	# Args
	level=$1
	prompt=$2

	# Display prompt
	lcolor $level "$prompt [Y/n]"

	# Get answer
	vared answer

	# If y then true, else false
	if [[ $answer:l == "y" ]]; then
		true
	else
		false
	fi
}

# Store value in file so that it persists throughout program runs.
# Key is the name of the file created in $ZSHCONF_PERSIST_DIR to store
# value.
#
# Value argument is optional, if not provided method just returns value
#
# Returns value
function persist_value() { # (key, value)
	# Args
	key=$1
	value=$2

	# File to store value in
	file="$ZSHCONF_PERSIST_DIR/$key"

	# File for key doesn't exist, create
	# Value exists
	# File doesn't exist
	if [[ ! -z ${value+x} ]] &&
	   [[ ! -a $file ]]; then
		mkdir -p "$ZSHCONF_PERSIST_DIR"
		touch $file
	fi

	# Update value if value provided
	if [[ -z ${value+x} ]]; then
		echo "222"
		echo $value > $file
	fi

	# Return value
	echo "f$file"
	echo "$(cat $file)"
}

# Checks if time stored with the persist_value method with name of identifier
# argument is an interval of seconds from the current time.
#
# Useful for automic update checking
# Returns true if interval of time has elapsed and sets persist value to time now
# for future use, returns false otherwise
function check_interval() { # (identifier, interval)
	# Args
	id=$1
	interval=$2

	# Store current time for future use
	now=$(date +%s)

	# Get existing interval value
	value=$(persist_value $id)

	# If value doesn't exist, set to now
	if [[ -z $value ]]; then
		value=$(persist_value $id $now)
	fi

	echo "val='$value'"

	# If interval has elapsed set interval value to current time for future use
	if (( $now - $value >= $interval)); then
		persist_value $id $now
		true
	else
		# Else return false
		false
	fi
}

# Check that Git is installed
if ! type git > /dev/null; then
	# If not err and exit
	llog $LOG_ERROR "Git not installed: Exiting"
	exit 1
fi

# Update zshconf
llog $LOG_UPDATE "Checking for zshconf update (self)"
if check_interval "self_update" $ZSHCONF_SELF_UPDATE_INTERVAL ; then
	# Make sure there is actually an update
	zshconf_self_git_hash=`git -C "$ZSHCONF_DIR" rev-parse HEAD` || llog $LOG_ERROR $zshconf_self_git_hash
	zshconf_remote_git_hash=`git -C "$ZSHCONF_DIR" rev-parse origin/master` || llog $LOG_ERROR $zshconf_remote_git_hash

	if [[ (zshconf_self_git_hash != zshconf_remote_git_hash) ]]; then
		llog $LOG_UPDATE "    Updating zshconf (self)"

		o=`git -C "$ZSHCONF_DIR" fetch --all 2>&1` || llog $LOG_ERROR $o
		o=`git -C "$ZSHCONF_DIR" reset --hard origin/master 2>&1` || llog $LOG_ERROR $o
	fi
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
					llog $LOG_UPDATE "Checking for update in repo $line"
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
