#!/bin/bash
false=0
true=1

read_default() {

	while IFS='=' read -r ext program; do
		[[ "$ext" =~ ^#.* ]] || [[ -z "$ext" ]] && continue

		if [[ "$ext" == "DEFAULT" ]]; then
			found=$true
			default_reader="$program"
		fi
	done < "$CONF_FILE"

	if [ $found -eq $false ]; then
		echo "NO DEFAULT PROGRAM FOUND" 1>&2
		exit 1
	fi
}

read_file_extension() {
    file_extension="${1##*.}"
}

exec_program() {
	found=$false
	while IFS='=' read -r ext program; do
	
		[[ "$ext" =~ ^#.* ]] || [[ -z "$ext" ]] && continue

		if [ "$ext" = "$file_extension" ]; then
			found=$true
			"$program" "$1" 
			exit 0
		fi
	done < "$CONF_FILE"
	
	if [ $found -eq $false ]; then
		"$default_reader" "$1"
		exit 0
	fi
}

if [ $# -lt 1 ]; then
    echo "NO PARAMETERS FOUND" 1>&2
    exit 1
fi

CONF_FILE="${AUTO_OPEN_CONF}programs.cfg"

read_default 
read_file_extension "$1"
exec_program "$1"
