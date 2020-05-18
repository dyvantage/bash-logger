#!/bin/bash

set -euo pipefail

: "${package_name:="$(basename "$(readlink -fm "$0")")"}"
: "${log_file:="$(dirname $(readlink -fm "$0"))/${package_name}.log"}"

# Source Logging Library
source ./logger.sh
if [ ! -f ${log_file} ]; then touch ${log_file}; fi

echo "log_file: ${log_file}"
test() {
    echo -e "\n\n"
    stdout "DEBUG_FLAG= ${debug_flag}"
    stdout "silent_debug= ${silent_debug}"
    stdout "Test stdout"
    info "Test info"
    debug "Test debug"
    # To test assert comment 'exit 1' in logger.sh assert() and uncomment below line
    #assert "Test assert"
}

debug_flag="0"
test

debug_flag="1"
test


debug_flag="2"
test

debug_flag="3"
test

silent_debug="1"
debug_flag="3"
test

cat ${log_file}
rm ${log_file}
