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
	echo "Usage: authenticate.sh <file> <claimedID> <Threshold>"
	echo
	echo "file         - WSQ file containing the fingerprint of the user to be authenticated"
	echo "claimedID    - The ID of the user claimed to match the given fingerprint"
	echo "Threshold    - Bozorth Threshold"
	echo
}

################################################################################
# The minimum requirement for the usage of the script are two parameters:
#	a wsq file and a user to be enrolled
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

# Directory the script is stored in
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#Directory for the NBIS tools
NBIS_DIR=

# Set log directory. If it doesn’t exist yet, create it
LOGDIR="$SCRIPT_DIR/log"
if [[ ! -d "$LOGDIR" ]];
	then
	`mkdir "$LOGDIR"`
fi

# Temporary directory. If it doesn’t exist yet, create it
TMPDIR="$SCRIPT_DIR/tmp"
if [[ ! -d "$TMPDIR" ]];
	then
	`mkdir "$TMPDIR"`
fi

ERRORLOG="$LOGDIR/errors"
DEBUGLOG="$LOGDIR/debug"

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

debuglog() {
	echo "$1" 2>&1 | tee -a $DEBUGLOG
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
BOZORTH_THRESHOLD=$3
PROVIDED_FINGERPRINT=$4
APPLY_SEGMENTATION=$5

USER_LOGFILE="$LOGDIR/log_$USER_ID"

################################################################################
# MAIN
################################################################################

NFIQ_OUTPUT=`$SCRIPT_DIR/bin/nfiq "$WSQ_INPUT"`
# Check if NFIQ is <= 3; if var is not assigned: set it to OVER NINE-THOUSAND
if [[ "${NFIQ_OUTPUT:-9001}" -le 3 ]];
	then
	#echo $NFIQ_OUTPUT > $USER_LOGFILE

	USERFILE="$SCRIPT_DIR/user_$USER_ID.xyt"
	if [[ ! -f $USERFILE ]]; then
		die "User with ID: $USER_ID does not exist." 7
	fi
	MINDTCT_OUTPUT=`$NBIS_DIR/mindtct "$WSQ_INPUT" "$TMPDIR/user_$USER_ID"`
	echo "$MINDTCT_OUTPUT"
	
	BOZORTH3_OUTPUT=`$NBIS_DIR/bozorth3 $TMPDIR/user_$USER_ID.xyt $USERFILE`
	# Check if BOZORTH3 Score is >= 40; if var is not assigned: set it to 0
	# Matches the score against the specified Threshold. If T is undefined: set it to 40
	if [[ "${BOZORTH3_OUTPUT:-0}" -ge "${BOZORTH_THRESHOLD:-40}" ]]; then
		debuglog "$BOZORTH3_OUTPUT"
		#echo "Authentication successful. Claimed user $USER_ID appears to match sample."
	else
		echo $BOZORTH3_OUTPUT > $USER_LOGFILE
		die "Sample appears not to be matching user file." 8		
	fi
	
# if NFIQ is higher than 3
else
	echo $NFIQ_OUTPUT > $USER_LOGFILE
	die "Bad fingerprint quality -- value is ${NFIQ_OUTPUT:-9001}, should be <= 3" 2
fi


# Delete tmp dir only if the script didn’t exit early on---files might be needed
delete_tmp

exit 0
