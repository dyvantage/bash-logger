#!/bin/bash

set -euo pipefail

: "${package_name:="$(basename "$(readlink -fm "$0")")"}"
: "${log_file:="$(dirname $(readlink -fm "$0"))/${package_name}.log"}"

# Source Logging Library
source ./logger.sh


echo "NO debug_flag"
echo -e "\nstdout_log: "; stdout_log "Test stdout_log"
echo -e "\ndebugging: "; debugging "Test debugging"

echo -e "\n\n\n"
debug_flag="1"
echo "SET debug_flag"
echo -e "\nstdout_log: "; stdout_log "Test stdout_log"
echo -e "\ndebugging: "; debugging "Test debugging"
echo -e "\nassert: "; assert "Test assert"
