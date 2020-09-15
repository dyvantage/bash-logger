#!/bin/bash

####################################################################################################
#   BASH-Logger
#   USAGE:  Source this file from the script you want to log from.
#           functions:
#               $ assert "assert message"
#                        Always print to stdout and send to log
#                        Exit script with exit code 1
#               $ stdout "stdout message"
#                        Always log and print to stdout using 'echo -e'"
#               $ info "INFO message"
#                        Always send to log
#                        Print to stdout when debug_flag > 0
#               $ debug "DEBUG message" to log"
#                        Only send to log when debug_flag > 1
#                        Only print to stdout when debug_flag > 2
#	    debug: Only sent to log if 'very verbose' is passed,
#		   Only sent to console if 'VERY VERY Verbose' is passed
#		   To reduce erronious processing, debug drops all messages unless debug_flag >= '2'
#   VARIABLES:
#           log_file: path to logfile [REQUIRED].
#           silent_debug: defaults to '0'
#               1 | enabled | supress all messages to stdout. Log as otherwise directed by debug_flag
#           debug_flag: defaults to '0'
#               0 | off               | display/log: [stdout, assert], log: [INFO], discard: [DEBUG] 
#               1 | verbose           | display/log: [stdout, assert, info], discard: [debug]
#               2 | very verbose      | display/log: [stdout, assert, info], log: [debug]
#               3 | extremely verbose | display/log: [stdout, assert, info, debug]
#
#
#   Each action above processes their message including leading tag and passes to log_and_print()
#   Final destination is log_and_print()
#       TimeStamp is calculated and prepended, then send to log
#       This function outputs messages based on the value of the debug_flag,
#         and leading TAG assigned by the sending functions
#       leading tag is removed from all messages before sending to stdout
#
####################################################################################################

set -euo pipefail

start_time=$(date +"%s.%N")

# Initialize variables and set default values
: "${debug_flag:=0}"
: "${silent_debug:=0}"
: "${package_name:="$(basename "$(readlink -fm "$0")")"}"
: "${log_file:=""}"
: "${init_log_file:=1}"

init_log_file() {
    if [ ! -f ${log_file} ]; then
	if [ ! -r $(dirname ${log_file}) ]; then
	    if ! $(mkdir -p $(dirname ${log_file})); then assert "Failed creating logfile directory: $(dirname ${log_file})"; fi
	fi
	if ! $(touch ${log_file}); then assert "Failed creating logfile: ${log_file}"; fi
	if [ ! -w ${log_file} ]; then assert "Creation of log file: ${log_file} failed."; fi
    fi
}

log_and_print() {
    if [ -f ${log_file} ]; then
        # Avoid error if bc is not installed yet
	if (which bc > /dev/null 2>&1); then
	    output="$(date +"%Y-%M-%d %T.%N") : $(bc <<<$(date +"%s.%N")-${start_time}) : $(basename $0) : ${1}"
	else
	    output="$(date +"%Y-%M-%d %T.%N") : $(basename $0) : ${1}"
	fi
        echo "${output}" 2>&1 >> ${log_file}
    fi
    # stdout to console
    if [[ ${silent_debug} -eq 0 ]]; then
	declare -a message=([0]=$(echo ${1} | cut -d ':' -f 1) [1]=$(echo ${1} | cut -d ':' -f 2-))
	case ${debug_flag} in
	    0)
		case ${message[0]} in
		    "TERM" | "FAIL")
			echo -e "${message[1]}"
			;;
		esac
	    ;;
	    1 | 2)
		case ${message[0]} in
		    "TERM" | "FAIL" | "INFO")
			echo -e "${message[1]}"
			;;
		esac
	    ;;
	    3)
		echo -e "${message[1]}"
	    ;;
	esac
    fi
}

assert() {
    output="${package_name} failed:"
    if [ $# -gt 0 ]; then
        output=" ${1}"
        if [ -f ${log_file} ]; then
	    output="${output}\nFailure occurred prior to log file being created\nTry re-running with --debug"
	else
	    output="${output}\nThe full log is available at ${log_file}\nIf more information is needed re-run with --debug"
	fi
    fi
    output="FAIL: ${1}"
    log_and_print "${output}"
    exit 1
}

stdout() {
    output="TERM: ${1}"
    log_and_print "${output}"
}

info() {
    output="INFO: ${1}"
    log_and_print "${output}"
}

debug() {
    if [[ ${debug_flag} -gt 1 ]]; then
	if [[ -n "${1:-}" ]]; then
	    log_and_print "DEBUG: ${1}"
	else
	    while read STDIN; do
		message=${message:-}$'\n        '$STDIN
	    done
	    log_and_print "DEBUG: ${message}"
	fi
    fi
}
