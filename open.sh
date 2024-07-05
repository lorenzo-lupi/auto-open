#!/bin/bash

read_default() {
	while IFS'=' read -r ext program; do
		[[ "$ext" =~ ^#.* ]] || [[ -z "$ext" ]] && continue

		if [[ "$ext" == "DEFAULT" ]]; then
			default_reader="$program"
		fi
	done < "$CONF_FILE"

	echo "NO DEFAULT PROGRAM FOUND" 1>&2
	exit 1
}

read_file_extension() {
    file_extension="${1##*.}"
}

exec_program() {
	while IFS='=' read -r ext program; do
	
		[[ "$ext" =~ ^#.* ]] || [[ -z "$ext" ]] && continue

		if [ "$ext" = "$file_extension" ]; then
			exec "$program" "$1"
			exit 0
		fi
	done < "$CONF_FILE"
	
	exec "$default_reader" "$1"
}

if [ $# -lt 1 ]; then
    echo "NO PARAMETERS FOUND" 1>&2
    exit 1
fi

CONF_FILE="programs.cfg"

read_file_extension "$1"
exec_program "$1"
