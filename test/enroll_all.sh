#!/bin/bash

################################################################################
# Display usage of the shell script
################################################################################
display_usage() {
	echo
	echo "Invalid number of arguments on command line"
	echo "Usage: enroll_all.sh <folder>"
	echo
	echo "folder - Folder containing wsq files of users to be enrolled"
	echo
}

################################################################################
# To start the script, the <folder> parameter is required
# The script therefore exits showing the usage of the script if the parameter
# 	count is less than one
################################################################################
if (( $# < 1 ))
	then
	display_usage
	exit 1
fi

##################################
# grep "GUT" because of the naming scheme chosen when creating the .wsq files:
#	$USERNAME_[LR]_[1-5]_(GUT|SCHLECHT)_[1-3]
##################################
for current_file in `ls $1 | grep "GUT"`; do
	without_suffix=`echo "$current_file" | cut -d'.' -f1`
	success=`./enrollment.sh "$1/$current_file" "$without_suffix"` 
	echo "$success"
done

exit 0


