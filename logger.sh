#!/bin/bash

####################################################################################################
#
#     The following functions have inter-dependancies assert(), stdout_log, debugging():
#     Each can be leveraged directly from the calling script.
#
#     Example:
#
####################################################################################################

set -euo pipefail

start_time=$(date +"%s.%N")

: "${debug_flag:=0}"
: "${package_name:="$(basename "$(readlink -fm "$0")")"}"
: "${log_file:=""}"

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
    if [[ ${debug_flag} -ne 0 ]]; then
	output="FAIL: ${1}"
    fi
    log_and_print "${output}"
    exit 1
}

########### TODO: ##########################
#   STDOUT: always to log, always to console
#   ASSERT: always to log, always to console
#   INFO: Always to log, only to console if 'verbose' is passed
#   DEBUG: only sent to log if 'very verbose' is passed,
#          Only sent to console if 'VERY VERY Verbose' is passed
#
#   Every action above processes their message fully (including leading tag)
#   TimeStamping is done by log()
#   Final destination is stdout_log() (or log_and_print())
#       This function will output all messages that are received
#       before echo -e should strip '^.*: ' (leading tag)
#       calculate and prepend timestamp then send to log
#   Determinations of what should be processed can occur here or in prior functions
#   Log Tags:
#	output="TERM: ${1}"
#	output="FAIL: ${1}"
#	output="DBUG: ${1}"
#	output="INFO: ${1}"
#
###################################################

stdout() {
    output="TERM: ${1}"
    log_and_print "${output}"
}

log_and_print() {
    if [ -f ${log_file} ]; then
        # Avoid error if bc is not installed yet
	if (which bc > /dev/null 2>&1); then
	    output="$(date +"%T") : $(bc <<<$(date +"%s.%N")-${start_time}) :$(basename $0) : ${1}"
	else
	    output="$(date +"%T") : $(basename $0) : ${1}"
	fi
        echo "${output}" 2>&1 >> ${log_file}
    fi
    # Process First tag here
    # If '^TERM:.*' |  '^ASSERT:.*';
    #     echo -e "output"
    # elif 
    #
    #'^TERM:.*' 
    if [[ ${debug_flag} -ne 0 ]]; then
    # CUT leading before echo!!!
    term=${1}
    echo -e "${term}"

}

info() {
    output="INFO: ${1}"
    log_and_print "${output}"
}

debugging() {
    if [[ ${debug_flag} -ne 0 ]]; then
	output="DBUG: ${1}"
	log_and_print "${output}"
    fi
}
