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

#
source ~/scripts/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE="true"
export GIT_PS1_SHOWUNTRACKEDFILE="true"
export GIT_PS1_SHOWUPSTREAM="auto"

U_GIT_PS1="${COLOR_LIGHT_PURPLE}\u@\h [\$(date +%k:%M:%S)]\n\$(bashrc_pretty_print_pwd 15)${BASHRC_GITINFO} \n${COLOR_DEFAULT} ${COLOR_WHITE}--| "

PS1=$U_GIT_PS1

