#!/bin/bash

################################################################################
# (c) Patrick Geselbracht <Patrick.Geselbracht@hsrw.org>
################################################################################

################################################################################
# Display usage of the shell script
################################################################################
display_usage() {
	echo
	echo "Invalid number of arguments on command line"
	echo "Usage: enrollment.sh <file> <ID>"
	echo
	echo "file - WSQ file containing the fingerprint of the user to be enrolled"
	echo "ID   - The ID of the user to be enrolled"
	echo
}

################################################################################
# The minimum requirement for the usage of the script are two parameters:
#	a wsq fil and a user to be enrolled
# The script therefore exits showing the usage of the script if the parameter
# 	count is less than two
################################################################################
if (( $# < 2 ))
	then
	display_usage
	exit 1
fi

if [[ "$(whoami)" == "root" ]];
	then
	echo "Unlike 42, sudo is not the Answer to the Ultimate Question of Life, the Universe, and Everything!"
	exit 1
fi

# Call the script that puts the relevant variables into memory
source ./variables.sh

################################################################################
# Returns the current time formated as YYYY-MM-DD_hh:mm:ss
################################################################################
timestamp() {
	date +"%F_%T"
}

################################################################################
# Show specified error message and exit the application w/ specified exit code
# Option vars referenced in this function hold the function's parameter values
# 	and should not be confused with the shell script's parameter variables.
# Option 1: Error message
# Option 2: Exit code
# Function writes the error message to stdout and to the ERRORLOG file
################################################################################
die() {
	echo `timestamp` "-- Error: $1" 2>&1 | tee -a $ERRORLOG
	exit $2
}

################################################################################
# Deletes the temporary directory
################################################################################
delete_tmp() {
	`rm -r "$TMPDIR"`
}

################################################################################
# PARAMETERS
################################################################################
WSQ_INPUT=$1
USER_ID=$2
PROVIDED_FINGERPRINT=$3
APPLY_SEGMENTATION=$4

USER_LOGFILE="$LOGDIR/log_$USER_ID"

################################################################################
# MAIN
################################################################################

if [[ ! -f "$NBIS_DIR/nfiq" ]];
	then
	die "NFIQ tool could not be found. Did you remember to add the directory you stored the NBIS tools in to 'variables.sh'?" 10
fi

NFIQ_OUTPUT=`$NBIS_DIR/nfiq "$WSQ_INPUT"`
# Check if NFIQ is <= 3; if var is not assigned: set it to OVER NINE-THOUSAND
if [[ "${NFIQ_OUTPUT:-9001}" -le 3 ]];
	then
	echo $NFIQ_OUTPUT > $USER_LOGFILE

	USERFILE="$SCRIPT_DIR/user_$USER_ID.xyt"
	if [[ -e $USERFILE ]]; then
		die "User with ID: $USER_ID already exists" 7
	else
		MINDTCT_OUTPUT=`$NBIS_DIR/mindtct "$WSQ_INPUT" "$TMPDIR/user_$USER_ID"`
		echo "$MINDTCT_OUTPUT"
	fi
# if NFIQ is higher than 3
else
	echo $NFIQ_OUTPUT > $USER_LOGFILE
	die "Bad fingerprint quality -- value is ${NFIQ_OUTPUT:-9001}, should be <= 3" 2
fi

#move minutae file to SCRIPT DIR
mv $TMPDIR/user_$USER_ID.xyt $USERFILE

# Delete tmp dir only if the script didn’t exit early on---files might be needed
delete_tmp

echo "Enrollment successful. User $USER_ID has been created."

exit 0
