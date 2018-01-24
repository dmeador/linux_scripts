#!/bin/bash

source ${HOME}/scripts/colors.sh

# Shell Prompt 
# 
#    \u – Username
#    \h – Hostname
#    \w – Full path of the current working directory



### In this section:
###  => 256 color support is enabled
###  => a super-duper fancy and dynamic bash prompt is created (over 5 lines with lots of info in it)
###           × requires at least 80 columns to work
###           × design continues at $PS2 to match the end of $PS1
###           × the first line is always empty (newline) ─ in case last program forgets to insert a newline to avoid "uglyness"
###           × colored and matching $PS3 in case a shell script uses 'select' without setting $PS3 internally
###        ─ the info of $PS1 ─
###           × users fullname from /etc/passwd
###           × machines hostname
###           × bash version
###           × current time (not updated dynamically ─ bash limitation)
###           × last exit status or signal name if it was a signal
###           × number of inodes in current working directory (excluding hidden ones .*)
###           × current working directory (dynamically formated, like bold slash and nice line wrapping)
###           × additional message of last exit code if it was a signal or bash builtin
###           × support for custom messages (last command + exit status)
###           × current running and stopped stops
###           × terminal type and number, example: tty1, tty2 for VT and pts/1, pts/2 for graphical terminals
###           × input prompt in its own line
###  => a super-duper fancy and dynamic xtrace ($PS4) line is created (full color and informative)
###           × more than 150 columns are highly recommended!
###  => other color specific things, like GCC_COLORS


BASHRC_TMPFS=/tmp/${USER}
# Write last command to file
function bashrc_write_lastcommand() {
		# Has minor issues with custom $PROMPT_COMMAND, need to add them here ;(
		if [[ "$BASH_COMMAND" != "history -a" && \
					"$BASH_COMMAND" != "history -c" && \
					"$BASH_COMMAND" != "history -r" ]]; then
				local LSTCMD="$BASH_COMMAND" # need this line,
																		 # because $BASH_COMMAND is already updated if you take a look at the next line
																		 # for security issues only store the command itself without its arguments
				printf "%s" "$(echo "$LSTCMD" | awk '{print $1}')" > "$BASHRC_TMPFS/lstcmd"
				LSTCMD=""
		fi
		
		# for performance reasons add to end of file: trap bashrc_write_lastcommand DEBUG
		touch "$BASHRC_TMPFS/lstcmd"
}

# Works togheter with 'bashrc_get_exitcode', prints custom messages depending on last command and exit status
function bashrc_extended_description_util() {
	if [ "$1" == "" ] ; then
		local EXIT=$(< "$BASHRC_TMPFS/exitcode")
		#local LSTCMD=$( "$BASHRC_TMPFS/exitcode" )
	elif [ "$1" == "description" ]; then
		EXIT=$(< "$BASHRC_TMPFS/exitcode")
		
		if   (( $EXIT == 126 )); then echo -e "\e[0;34m$BASHSIG_EXEC\e[0m";    # 126 BASH: exec error
		elif (( $EXIT == 127 )); then echo -e "\e[0;34m$BASHSIG_CNF\e[0m";     # 127 BASH: command not found
		elif (( $EXIT == 128 )); then echo -e "\e[0;34m$BASHSIG_EXIT\e[0m";    # 128 BAHS: invalid argument to exit
		
		# *NIX (POSIX, BSD, ANSI) Signals found on most common Unix-like operating systems
		elif (( $EXIT == 129 )); then echo -e "$SIGHUP";       # 129 n=1  SIGHUP  (hangup)
		elif (( $EXIT == 130 )); then echo -e "$SIGINT";       # 130 n=2  SIGINT  (interupt)
		elif (( $EXIT == 131 )); then echo -e "$SIGQUIT";      # 131 n=3  SIGQUIT (quit and core dump)
		elif (( $EXIT == 132 )); then echo -e "$SIGILL";       # 132 n=4  SIGILL  (illegal instruction)
		elif (( $EXIT == 133 )); then echo -e "$SIGTRAP";      # 133 n=5  SIGTRAP (trace/breakpoint trap)
		elif (( $EXIT == 134 )); then echo -e "$SIGABRT";      # 134 n=6  SIGABRT (abort)
		elif (( $EXIT == 135 )); then echo -e "$SIGBUS";       # 135 n=7  SIGBUS  (bus error)
		elif (( $EXIT == 136 )); then echo -e "$SIGFPE";       # 136 n=8  SIGFPE  (erroneous arithmetic operation)
		elif (( $EXIT == 137 )); then echo -e "$SIGKILL";      # 137 n=9  SIGKILL (killed)
		elif (( $EXIT == 138 )); then echo -e "$SIGUSR1";      # 138 n=10 SIGUSR1 (user defined signal 1)
		elif (( $EXIT == 139 )); then echo -e "$SIGSEGV";      # 139 n=11 SIGSEGV (segmentation fault)
		elif (( $EXIT == 140 )); then echo -e "$SIGUSR2";      # 140 n=12 SIGUSR2 (user defined signal 2)
		elif (( $EXIT == 141 )); then echo -e "$SIGPIPE";      # 141 n=13 SIGPIPE (broken pipe)
		elif (( $EXIT == 142 )); then echo -e "$SIGALRM";      # 142 n=14 SIGALRM (alarm clock)
		elif (( $EXIT == 143 )); then echo -e "$SIGTERM";      # 143 n=15 SIGTERM (termination)
		elif (( $EXIT == 144 )); then echo -e "$SIGSTKFLT";    # 144 n=16 SIGSTKFLT (stack fault)
		elif (( $EXIT == 145 )); then echo -e "$SIGCHLD";      # 145 n=17 SIGCHLD (child stopped or exited)
		elif (( $EXIT == 146 )); then echo -e "$SIGCONT";      # 146 n=18 SIGCONT (continue execution SIGSTOP)
		elif (( $EXIT == 147 )); then echo -e "$SIGSTOP";      # 147 n=19 SIGSTOP (stop execution)
		elif (( $EXIT == 148 )); then echo -e "$SIGTSTP";      # 148 n=20 SIGTSTP (terminal stop)
		elif (( $EXIT == 149 )); then echo -e "$SIGTTIN";      # 149 n=21 SIGTTIN (bg process trying to read tty)
		elif (( $EXIT == 150 )); then echo -e "$SIGTTOU";      # 150 n=22 SIGTTOU (bg process trying to write tty)
		elif (( $EXIT == 151 )); then echo -e "$SIGURG";       # 151 n=23 SIGURG  (urgent condition on socket)
		elif (( $EXIT == 152 )); then echo -e "$SIGXCPU";      # 152 n=24 SIGXCPU (cpu limit exceeded)
		elif (( $EXIT == 153 )); then echo -e "$SIGXFSZ";      # 153 n=25 SIGXFSZ (file size limit exceeded)
		elif (( $EXIT == 154 )); then echo -e "$SIGVTALRM"     # 154 n=26 SIGVTALRM (virtual timer expired)
		elif (( $EXIT == 155 )); then echo -e "$SIGPROF"       # 155 n=27 SIGPROF (profiling timer expired)
		elif (( $EXIT == 156 )); then echo -e "$SIGWINCH";     # 156 n=28 SIGWINCH (window size change)
		elif (( $EXIT == 157 )); then echo -e "$SIGIO";        # 157 n=29 SIGIO   (I/O now possible)
		elif (( $EXIT == 158 )); then echo -e "$SIGPWR";       # 158 n=30 SIGPWR  (power failure)
		else bashrc_extended_description_util;
		fi
	elif [ "$1" == "description-size" ]; then
		EXIT=$(< "$BASHRC_TMPFS/exitcode")
		
		if   (( $EXIT == 126 )); then echo "${#BASHSIG_EXEC}"; # 126 BASH: exec error
		elif (( $EXIT == 127 )); then echo "${#BASHSIG_CNF}";  # 127 BASH: command not found
		elif (( $EXIT == 128 )); then echo "${#BASHSIG_EXIT}"; # 128 BAHS: invalid argument to exit
		
		# *NIX (POSIX, BSD, ANSI) Signals found on most common Unix-like operating systems
		elif (( $EXIT == 129 )); then echo "${#SIGHUP}";       # 129 n=1  SIGHUP  (hangup)
		elif (( $EXIT == 130 )); then echo "${#SIGINT}";       # 130 n=2  SIGINT  (interupt)
		elif (( $EXIT == 131 )); then echo "${#SIGQUIT}";      # 131 n=3  SIGQUIT (quit and core dump)
		elif (( $EXIT == 132 )); then echo "${#SIGILL}";       # 132 n=4  SIGILL  (illegal instruction)
		elif (( $EXIT == 133 )); then echo "${#SIGTRAP}";      # 133 n=5  SIGTRAP (trace/breakpoint trap)
		elif (( $EXIT == 134 )); then echo "${#SIGABRT}";      # 134 n=6  SIGABRT (abort)
		elif (( $EXIT == 135 )); then echo "${#SIGBUS}";       # 135 n=7  SIGBUS  (bus error)
		elif (( $EXIT == 136 )); then echo "${#SIGFPE}";       # 136 n=8  SIGFPE  (erroneous arithmetic operation)
		elif (( $EXIT == 137 )); then echo "${#SIGKILL}";      # 137 n=9  SIGKILL (killed)
		elif (( $EXIT == 138 )); then echo "${#SIGUSR1}";      # 138 n=10 SIGUSR1 (user defined signal 1)
		elif (( $EXIT == 139 )); then echo "${#SIGSEGV}";      # 139 n=11 SIGSEGV (segmentation fault)
		elif (( $EXIT == 140 )); then echo "${#SIGUSR2}";      # 140 n=12 SIGUSR2 (user defined signal 2)
		elif (( $EXIT == 141 )); then echo "${#SIGPIPE}";      # 141 n=13 SIGPIPE (broken pipe)
		elif (( $EXIT == 142 )); then echo "${#SIGALRM}";      # 142 n=14 SIGALRM (alarm clock)
		elif (( $EXIT == 143 )); then echo "${#SIGTERM}";      # 143 n=15 SIGTERM (termination)
		elif (( $EXIT == 144 )); then echo "${#SIGSTKFLT}";    # 144 n=16 SIGSTKFLT (stack fault)
		elif (( $EXIT == 145 )); then echo "${#SIGCHLD}";      # 145 n=17 SIGCHLD (child stopped or exited)
		elif (( $EXIT == 146 )); then echo "${#SIGCONT}";      # 146 n=18 SIGCONT (continue execution SIGSTOP)
		elif (( $EXIT == 147 )); then echo "${#SIGSTOP}";      # 147 n=19 SIGSTOP (stop execution)
		elif (( $EXIT == 148 )); then echo "${#SIGTSTP}";      # 148 n=20 SIGTSTP (terminal stop)
		elif (( $EXIT == 149 )); then echo "${#SIGTTIN}";      # 149 n=21 SIGTTIN (bg process trying to read tty)
		elif (( $EXIT == 150 )); then echo "${#SIGTTOU}";      # 150 n=22 SIGTTOU (bg process trying to write tty)
		elif (( $EXIT == 151 )); then echo "${#SIGURG}";       # 151 n=23 SIGURG  (urgent condition on socket)
		elif (( $EXIT == 152 )); then echo "${#SIGXCPU}";      # 152 n=24 SIGXCPU (cpu limit exceeded)
		elif (( $EXIT == 153 )); then echo "${#SIGXFSZ}";      # 153 n=25 SIGXFSZ (file size limit exceeded)
		elif (( $EXIT == 154 )); then echo "${#SIGVTALRM}";    # 154 n=26 SIGVTALRM (virtual timer expired)
		elif (( $EXIT == 155 )); then echo "${#SIGPROF}";      # 155 n=27 SIGPROF (profiling timer expired)
		elif (( $EXIT == 156 )); then echo "${#SIGWINCH}";     # 156 n=28 SIGWINCH (window size change)
		elif (( $EXIT == 157 )); then echo "${#SIGIO}";        # 157 n=29 SIGIO   (I/O now possible)
		elif (( $EXIT == 158 )); then echo "${#SIGPWR}";       # 158 n=30 SIGPWR  (power failure)
		else bashrc_extended_description_util size;
		fi
	else # no parameters
		if (( $EXIT ==  0 )) ; then   # EXIT=$( success ) 
																									echo -e "\e[0;44m\e[97mSUCCESS\e[0m"    # 0 

		#elif (( $EXIT >  0 ))  # $EXIT  error ))
		elif (( $EXIT == 126 )); then                  echo -e "\e[0;44m\e[97mEXEC\e[0m";  # 126      blue -> EXEC error
		elif (( $EXIT == 127 )); then                  echo -e "\e[0;44m\e[97mCNF\e[0m";   # 127      blue -> CNF error
		elif (( $EXIT == 128 )); then                  echo -e "\e[0;44m\e[97mEXIT\e[0m";  # 128      blue -> EXIT error
		
		# *NIX (POSIX, BSD, ANSI) Signals found on most common Unix-like operating systems
		elif (( $EXIT == 129 )); then       echo -e "\e[0;35mSIGHUP\e[0m";       # 129 n=1  SIGHUP  (hangup)
		elif (( $EXIT == 130 )); then echo -e "\e[0;45m\e[97mSIGINT\e[0m";       # 130 n=2  SIGINT  (interupt)
		elif (( $EXIT == 131 )); then       echo -e "\e[0;35mSIGQUIT\e[0m";      # 131 n=3  SIGQUIT (quit and core dump)
		elif (( $EXIT == 132 )); then echo -e "\e[0;41m\e[97mSIGILL\e[0m";       # 132 n=4  SIGILL  (illegal instruction)
		elif (( $EXIT == 133 )); then       echo -e "\e[0;35mSIGTRAP\e[0m";      # 133 n=5  SIGTRAP (trace/breakpoint trap)
		elif (( $EXIT == 134 )); then       echo -e "\e[0;35mSIGABRT\e[0m";      # 134 n=6  SIGABRT (abort)
		elif (( $EXIT == 135 )); then       echo -e "\e[0;35mSIGBUS\e[0m";       # 135 n=7  SIGBUS  (bus error)
		elif (( $EXIT == 136 )); then echo -e "\e[0;41m\e[97mSIGFPE\e[0m";       # 136 n=8  SIGFPE  (erroneous arithmetic operation)
		elif (( $EXIT == 137 )); then echo -e "\e[0;45m\e[97mSIGKILL\e[0m";      # 137 n=9  SIGKILL (killed)
		elif (( $EXIT == 138 )); then echo -e "\e[0;46m\e[97mSIGUSR1\e[0m";      # 138 n=10 SIGUSR1 (user defined signal 1)
		elif (( $EXIT == 139 )); then echo -e "\e[0;41m\e[97mSIGSEGV\e[0m";      # 139 n=11 SIGSEGV (segmentation fault)
		elif (( $EXIT == 140 )); then echo -e "\e[0;46m\e[97mSIGUSR2\e[0m";      # 140 n=12 SIGUSR2 (user defined signal 2)
		elif (( $EXIT == 141 )); then       echo -e "\e[0;35mSIGPIPE\e[0m";      # 141 n=13 SIGPIPE (broken pipe)
		elif (( $EXIT == 142 )); then       echo -e "\e[0;35mSIGALRM\e[0m";      # 142 n=14 SIGALRM (alarm clock)
		elif (( $EXIT == 143 )); then echo -e "\e[0;45m\e[97mSIGTERM\e[0m";      # 143 n=15 SIGTERM (termination)
		elif (( $EXIT == 144 )); then echo -e "\e[0;41m\e[97mSIGSTKFLT\e[0m";    # 144 n=16 SIGSTKFLT (stack fault)
		elif (( $EXIT == 145 )); then       echo -e "\e[0;35mSIGCHLD\e[0m";      # 145 n=17 SIGCHLD (child stopped or exited)
		elif (( $EXIT == 146 )); then echo -e "\e[0;44m\e[97mSIGCONT\e[0m";      # 146 n=18 SIGCONT (continue execution SIGSTOP)
		elif (( $EXIT == 147 )); then echo -e "\e[0;44m\e[97mSIGSTOP\e[0m";      # 147 n=19 SIGSTOP (stop execution)
		elif (( $EXIT == 148 )); then echo -e "\e[0;44m\e[97mSIGTSTP\e[0m";      # 148 n=20 SIGTSTP (terminal stop)
		elif (( $EXIT == 149 )); then echo -e "\e[0;44m\e[97mSIGTTIN\e[0m";      # 149 n=21 SIGTTIN (bg process trying to read tty)
		elif (( $EXIT == 150 )); then echo -e "\e[0;44m\e[97mSIGTTOU\e[0m";      # 150 n=22 SIGTTOU (bg process trying to write tty)
		elif (( $EXIT == 151 )); then       echo -e "\e[0;35mSIGURG\e[0m";       # 151 n=23 SIGURG  (urgent condition on socket)
		elif (( $EXIT == 152 )); then echo -e "\e[0;43m\e[97mSIGXCPU\e[0m";      # 152 n=24 SIGXCPU (cpu limit exceeded)
		elif (( $EXIT == 153 )); then echo -e "\e[0;43m\e[97mSIGXFSZ\e[0m";      # 153 n=25 SIGXFSZ (file size limit exceeded)
		elif (( $EXIT == 154 )); then echo -e "\e[0;43m\e[97mSIGVTALRM\e[0m"     # 154 n=26 SIGVTALRM (virtual timer expired)
		elif (( $EXIT == 155 )); then echo -e "\e[0;43m\e[97mSIGPROF\e[0m"       # 155 n=27 SIGPROF (profiling timer expired)
		elif (( $EXIT == 156 )); then       echo -e "\e[0;35mSIGWINCH\e[0m";     # 156 n=28 SIGWINCH (window size change)
		elif (( $EXIT == 157 )); then echo -e "\e[0;40m\e[97mSIGIO\e[0m";        # 157 n=29 SIGIO   (I/O now possible)
		elif (( $EXIT == 158 )); then echo -e "\e[1;41m\e[97mSIGPWR\e[0m"        # 158 n=30 SIGPWR  (power failure)
		
		elif (( $EXIT >  158 )); then echo -e "\e[1;41m\e[97m$EXIT\e[0m"        # 158 n>30 UNKNOWN/UNDEFINED failure)
		elif (( $EXIT == 255 )); then                  echo -e "\e[1;31m$EXIT\e[0m"; # 255      red (bold) -> exit status exceed
		else                                           echo            "$EXIT";      # *        black [just in case]
		fi
	fi
}

# Get current system time in format HH:MM:SS
function bashrc_get_currenttime() {
	date +"%T"
}

# Get jobs currently running and stopped ─ contains length of string for separator function
function bashrc_get_jobscount() {
	 local stopped="$(jobs -s | wc -l | tr -d " ")"
	 local running="$(jobs -r | wc -l | tr -d " ")"
	 local jobs_string="${running}r/${stopped}s"
	 local jobs_strsize="${#jobs_string}"
	 if [ "$1" == "strsize" ]; then echo "$jobs_strsize"
	 else echo "$jobs_string"
	 fi
}

# Inserts a separator of $1, optimal: substrate $2 number to fill the rest of the line
function bashrc_insert_separator() {
	# define local variables
	local fillsize=""
	local fill=""
	# check if $1 exists, if not set it to space
	local fillchar=${1:-" "}
	# check if $2 exists, if not set it to 0
	local minusfill=${2:-"0"}
	# calculate fillsize
	let fillsize=$(($(tput cols) - $minusfill))
	# insert separator
	if [ "$fillchar" == " " ]; then printf '%*s\n' "${fillsize}" ''
	else
		while [ "$fillsize" -gt "0" ]; do
				fill="$fillchar${fill}"
				let fillsize=${fillsize}-1
		done
		# print separator
		echo $fill
	fi
}

function bashrc_get_exitcode() {
	echo -n "";
}

# This function prints the current working directory on screen, but with some little extras
#  -- respect terminal columns and enters a newline instead of the ugly line wrapping
#  -- don't trim in middle of file or folder name if no space left
#     makes it easier to see the directory tree
#     if for some reason the file/folder name is longer than the terminal columns, the name is wrapped into a new line
#  -- perfect for fancy dynamic bash prompts
#
#  Usage: $0 [int-extra-indentation-for-firstline]
#            (-16)
function bashrc_pretty_print_pwd() {
	# every possible new line starts with this (except the first one)
	local newline_starter="# | "
	
	# every possible line ends with this (including first one)
	local newline_ender="  "

	# calculate available space
	local columns_firstline=$(($(tput cols) - ${#newline_ender} - $1))
	local columns=$(($columns_firstline - ${#newline_starter}))
	
	# store 'pwd' into an array, split at directory indicator '/'
	local pwd="$(pwd)"
	pwd="${pwd/$HOME/\~}" # replace $HOME path with tilde
	IFS='/' read -r -a pwd <<< "$pwd"
	[ -z "${pwd[0]}" ] && pwd=("${pwd[@]:1}")
	
	# create output buffer (contains escape sequences)
	local outbuf
	
	# append first '/' if not starts with tilde~
	[ "${pwd[0]}" != "~" ] && outbuf+="/"
	
	# TODO 
	for i in "${pwd[@]}"; do
		outbuf+="${i}/"
	done
	
	# finalize string ─ bold the directory indicator '/'
	if (( ${#outbuf} != 1 )); then outbuf="${outbuf::-1}"; fi
	outbuf="$(echo "$outbuf" | sed 's/\//\\e\[1m\/\\e\[0m/g')"
	outbuf="$(echo "$outbuf" | sed 's/~/\\e[90m~\\e[0m/1')"
	echo -e -n "$outbuf"
}

#————————————————————-
# GIT on Prompt
#————————————————————-
function _git_color_status()
{
status=”`git status –porcelain 2>/dev/null`”

#not a git repository
if [ $? -ne 0 ]; then
echo -ne $darkgray
elif [ `echo “$status” | grep “M” | wc -l` != “0” ]; then
echo -ne $red
elif [ `echo “$status” | grep “A” | wc -l` != “0” ]; then
echo -ne $yellow
elif [ `echo “$status” | grep “??” | wc -l` != “0” ]; then
echo -ne $cyan
else
echo -ne $HILIT2
fi
}

##################################################################################
# PS1 ─ User Input                                                               #
##################################################################################

# executed only once per session ─ this code greps the full username from the /etc/passwd file
# -- workaround for a 'all-lowercase-username', Redhed-based distros doesn't have this issue
# -- personally I prefer a free usernaming like Redhed-based distros does
PASSWD_CURRENT_USER_FULLNAME="$(awk -F":" '{ print $1$5 }' /etc/passwd | grep $(whoami) | sed "s/^$(whoami)//")"

# executed only once per session ─ this code generates the header line (along with its size for the separator function)
BASHRC_USERHOSTNAME="$PASSWD_CURRENT_USER_FULLNAME@\[$(tput bold && tput setaf 1)\]\h\[$(tput sgr0)\]"
BASHRC_USERHOSTNAME_SIZE="$PASSWD_CURRENT_USER_FULLNAME@$(hostname)"
BASHRC_USERHOSTNAME_SIZE=${#BASHRC_USERHOSTNAME_SIZE}
BASHRC_LOCALTIME_SIZE="$(bashrc_get_currenttime)"
BASHRC_LOCALTIME_SIZE=${#BASHRC_LOCALTIME_SIZE}
BASHRC_BASH_VERSION_STRING="$(tput bold && tput setaf 5)GNU/Bash:$(tput sgr0) $BASH_VERSION"
BASHRC_BASH_VERSION_SIZE=${#BASHRC_BASH_VERSION_STRING}
PS1_HEADER_SIZE=$(($BASHRC_USERHOSTNAME_SIZE + $BASHRC_LOCALTIME_SIZE + $BASHRC_BASH_VERSION_SIZE + 3))
unset BASHRC_USERHOSTNAME_SIZE
unset BASHRC_LOCALTIME_SIZE
unset BASHRC_BASH_VERSION_SIZE
BASHRC_GITINFO="${COLOR_CYAN}\$(__git_ps1 \" (%s)\" )$(tput sgr0)"
#BASHRC_GITINFO="$(_git_color_status)"

BASHRC_TERMINAL="$(tty | sed 's/^\/dev\///')"
BASHRC_TERMINAL_SIZE=${#BASHRC_TERMINAL}

# executed each time when a command finished
PS1_HEADER="# -- ${BASHRC_USERHOSTNAME} -\$(bashrc_insert_separator - $PS1_HEADER_SIZE)- ${BASHRC_BASH_VERSION_STRING} ---- \$(bashrc_get_currenttime)\n"
PS1_MAINLINE="# [\$(bashrc_get_exitcode)] CWD[\$(ls | wc -l)]: \$(bashrc_pretty_print_pwd 15) ${BASHRC_GITINFO} \n"
PS1_INFOLINE="# \$(bashrc_get_exitcode description) \$(bashrc_insert_separator \" \" \$((\$(bashrc_get_jobscount strsize) + $BASHRC_TERMINAL_SIZE + 30 + \$(bashrc_get_exitcode description-size)))) [$(tput bold && tput setaf 4)Jobs:$(tput sgr0) \$(bashrc_get_jobscount)] [$(tput setaf 5)Terminal:$(tput sgr0) ${BASHRC_TERMINAL}]\n"
PS1_CMDINPUT="# > "


#PS1="\$(bashrc_get_exitcode set)$(tput sgr0)\n${PS1_HEADER}${PS1_MAINLINE}${PS1_INFOLINE}${PS1_CMDINPUT}"

##################################################################################
# PS2 ─ Wait for more User Input (multiline)                                 (\) #
##################################################################################
PS2="#   "

##################################################################################
# PS3 ─ select prompt     [in case there is no one set internally in the script] #
##################################################################################
#export PS3="# $(tput bold)[select]$(tput sgr0) > "

##################################################################################
# PS4 ─ Script Debugging                                                (xtrace) #
##################################################################################
# # $script_name@line[$LINENO] > $function(): $line_content
#export PS4="# \e[38;5;239m(xtrace)\e[0m \e[4m\e[90m\$(basename \"\${BASH_SOURCE}\")\e[39m@\e[3mline\e[1m[\${LINENO}]\e[24m \e[1;34m>\e[0m \e[38;5;105m\${FUNCNAME[0]}()\e[0m: "





#echo $PWD
#bashrc_pretty_print_pwd "123"
#
source ~/scripts/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE="true"
export GIT_PS1_SHOWUNTRACKEDFILE="true"
export GIT_PS1_SHOWUPSTREAM="auto"

U_GIT_PS1="${COLOR_LIGHT_PURPLE}\u@\h [\$(date +%k:%M:%S)]\n\$(bashrc_pretty_print_pwd 15)${BASHRC_GITINFO} \n${COLOR_DEFAULT} ${COLOR_WHITE}--| "
# example prompts
#A_PS1='\[\e[0m\]\[\e[48;5;236m\]\[\e[38;5;105m\]\u\[\e[38;5;105m\]@\[\e[38;5;105m\]\h\[\e[38;5;105m\] \[\e[38;5;221m\]\w\[\e[38;5;221m\]\[\e[38;5;105m\]\[\e[0m\]\[\e[38;5;236m\]\342\226\214\342\226\214\342\226\214\[\e[0m\]'
#
#if [[ ${EUID} == 0 ]] ; then
#B_PS1='\e[1;31;48;5;234m\u \e[38;5;240mon \e[1;38;5;28;48;5;234m\h \e[38;5;54m\d \@\e[0m\n\e[0;31;48;5;234m[\w] \e[1m\$\e[0m '
#else
#B_PS1='\e[1;38;5;56;48;5;234m\u \e[38;5;240mon \e[1;38;5;28;48;5;234m\h \e[38;5;54m\d \@\e[0m\n\e[0;38;5;56;48;5;234m[\w] \e[1m\$\e[0m '
#PS1='\[\e[0m\]\[\e[48;5;236m\]\[\e[38;5;105m\]\u\[\e[38;5;105m\]@\[\e[38;5;105m\]\h\[\e[38;5;105m\] \[\e[38;5;221m\]\w\[\e[38;5;221m\]\[\e[38;5;105m\]$(__git_ps1)\[\e[0m\]\[\e[38;5;236m\]\342\226\214\342\226\214\342\226\214\[\e[0m\]'
#fi


PS1=$U_GIT_PS1

