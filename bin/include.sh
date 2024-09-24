
echo_black()    { [ "$TERM" ] && tput setaf 0; echo -e "$@"; [ "$TERM" ] && tput sgr0; }
echo_red()      { [ "$TERM" ] && tput setaf 1; echo -e "$@"; [ "$TERM" ] && tput sgr0; }
echo_green()    { [ "$TERM" ] && tput setaf 2; echo -e "$@"; [ "$TERM" ] && tput sgr0; }
echo_yellow()   { [ "$TERM" ] && tput setaf 3; echo -e "$@"; [ "$TERM" ] && tput sgr0; }
echo_blue()     { [ "$TERM" ] && tput setaf 4; echo -e "$@"; [ "$TERM" ] && tput sgr0; }
echo_magenta()  { [ "$TERM" ] && tput setaf 5; echo -e "$@"; [ "$TERM" ] && tput sgr0; }
echo_cyan()     { [ "$TERM" ] && tput setaf 6; echo -e "$@"; [ "$TERM" ] && tput sgr0; }
echo_white()    { [ "$TERM" ] && tput setaf 7; echo -e "$@"; [ "$TERM" ] && tput sgr0; }

try_cmd() {
	# Run a command, if it fails, try again after 'pause' seconds
	# Usage: try_cmd [-q] <pause> <interval> <total>
	local quiet=
	[ "$1" = "-q" ] && local quiet=1 && shift
	local pause=$1; shift		# initial pause time in sec
	local interval=$1; shift	# add interval to pause time
	local total=$1; shift		# total number of tries

	local count=1

	[ ! "$quiet" ] && echo "Attempt $count/$total of command: \"$*\""

	while ! eval $*
	do
		if [ ! "$quiet" ]; then
			[ $count -ge $total ] && echo "Giving up!" && return 1
			echo Pausing $pause seconds ...
		fi
		sleep $pause

		let pause=$pause+$interval
		let count=$count+1

		[ ! "$quiet" ] && echo "Attempt $count/$total of command: \"$*\""
	done
}


