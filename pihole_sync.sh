#!/bin/bash

###########################
### BEGIN CONFIGURATION ###
###########################

# Define PiHole node name
node_name=PiHole

# Designate whether this node is the 'master' or 'slave'
node_type=master

# Local PiHole directory
LOCAL_DIR=/etc/pihole

# Remote Rsync directory
REMOTE_DIR=/home/pi/PiHole-list-sync

# IP address of Slave PiHole

IP_ADDR=xxx.xxx.xxx.xxx 

###########################
#### END CONFIGURATION ####
###########################

# Create initial syslog entry

# If this is the master node
if [[ $node_type == "master" ]]; then
	logger "pihole_sync: Node type is master"
	# Files to sync
	FILES=(black.list blacklist.txt gravity.list regex.list whitelist.txt adlists.list)

	# Sync specified files
	for FILE in ${FILES[@]}
	do
		scp -i ~/.ssh/id_rsa $LOCAL_DIR/$FILE pi@$IP_ADDR:$REMOTE_DIR
		sleep 5
	done
fi

# If this is the slave node
if [[ $node_type == "slave" ]]; then
	# Pause while the master node completes its sync
	sleep 180

	logger "pihole_sync: Node type is slave"
	# Files to sync
	FILES=(black.list blacklist.txt regex.list whitelist.txt)
	ADLISTS=(gravity.list adlists.list)

	# Sync flags
	SYNC1=0
	SYNC2=0

	# Determine whether to sync files
	for FILE in ${FILES[@]}
	do
        	# Check if the remote file is newer than the local file
	        if [[ "$REMOTE_DIR/$FILE" -nt "$LOCAL_DIR/$FILE" ]]; then
        	        # If the remote file is newer, then enable sync
                	((SYNC1++))
	                logger "pihole_sync:" $FILE "needs to be synced"
        	else
                	logger "pihole_sync:" $FILE "does not need to be synced"
	        fi
	done

	# Sync files
	if [[ "$SYNC1" -ge 1 ]]; then
	        for FILE in ${FILES[@]}
	        do
	                cp -u $REMOTE_DIR/$FILE $LOCAL_DIR/$FILE
	        done
	fi
	
	# Determine whether to sync files
	for ADLISTS in ${ADLISTS[@]}
	do
        	# Check if the remote file is newer than the local file
	        if [[ "$REMOTE_DIR/$ADLISTS" -nt "$LOCAL_DIR/$ADLISTS" ]]; then
        	        # If the remote file is newer, then enable sync
                	((SYNC2++))
	        fi
	done

	# Sync files and update Gravity
	if [[ "$SYNC2" -ge 1 ]]; then
	        for ADLISTS in ${ADLISTS[@]}
	        do
	                cp -u $REMOTE_DIR/$ADLISTS $LOCAL_DIR/$ADLISTS
	        done
	        pihole restartdns
	fi
fi

exit 0
