#!/bin/bash

##################################
# grep "user_" because of the naming scheme chosen when creating the .wsq files:
#	user_$USERNAME_[LR]_[1-5]_(GUT|SCHLECHT)_[1-3]
# 'cut' ultimately cuts the .wsq suffix, leaving just the file name 
##################################
for enrolled_finger in `ls | grep "user_" | cut -d'.' -f1`; do
	
	# Cuts the "user_" part from the file name
	enrld_fing_wo_usr=`echo $enrolled_finger | cut -c 6-30`
	# Cuts the index succeeding "GUT"	
	enrld_fing_wo_usr_wo_idx=`echo $enrld_fing_wo_usr | cut -c 1-14`

	# Find all files iterating through the current folder and its subfolders that:
	# 	- End w/ .wsq and contain "GUT"
	for wsq in `ls -R | grep ".*GUT.*[.]wsq$" ` ; do
		
		# Cuts the suffix, leaving just the file name
		wsq_wo_suffix=`echo $wsq | cut -d'.' -f1`
		# Cuts the index off the already shortened wsq filename
		wsq_wo_suffix_wo_index=`echo $wsq_wo_suffix | cut -c 1-14` 

		# Conditional to prevent matching against itself
		if [[ "$wsq_wo_suffix_wo_index" != "$enrld_fing_wo_usr_wo_idx" ]]; then
			userdir=`echo $wsq_wo_suffix_wo_index | cut -c 1-5`			

			authentication=`./authenticate.sh "$userdir/$wsq" "$enrld_fing_wo_usr" 1`
			echo "$authentication" 
		fi
	done
done

exit 0
