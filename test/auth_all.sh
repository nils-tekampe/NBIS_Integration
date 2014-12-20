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
	#	- Match against the filename of the enrolled finger
	#		w/o user prefix and w/o succeeding repetition index
	for wsq in `ls -R | grep ".*GUT.*[.]wsq$" | grep "$enrld_fing_wo_usr_wo_idx" ` ; do
		
		# Cuts the suffix, leaving just the file name
		wsq_wo_suffix=`echo $wsq | cut -d'.' -f1`

		# Conditional to prevent authenticating against itself
		if [[ "$wsq_wo_suffix" != "$enrld_fing_wo_usr" ]]; then
			#echo "About to match $wsq_wo_suffix against $enrolled_finger"
			userdir=`echo $enrld_fing_wo_usr | cut -c 1-5`			

			# Authentication script params used: <wsq>, <claimed user id>, <bozorth3 treshold>
			authentication=`./authenticate.sh "$userdir/$wsq" "$enrld_fing_wo_usr" 1`
			echo "$authentication" 
		fi
	done
done

exit 0
