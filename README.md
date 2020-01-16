gadkarisid# pihole-sync

## Introduction
This script is meant to keep 2 PiHole instances in sync. One node is designated as the master and the other node is the slave. 
This is a fork from gadkarisid pihole-sync repo. I just hacked it in an ugly way. But works for me :). 


All maintenance (adding blocklists, adding entries to whitelist/blacklist/regex) should be done on the master node. The master node will upload those files connects to the Backup PiHole with scp Privat/Public key combination.  
The slave node will check the uploaded files and sync them if necceccary. 

### Usage
- create a ssh key pair on the master PiHole and upload the public key to the slave PiHole
- Copy pihole_sync.sh to the folder of your choice on both PiHole nodes. 
- Update the options in the configuration section. 
- Run script as pi user on the master PiHole
- Run script as sudo user on the slave PiHole (bocklist owned by root) 
- create cronjob on Master as pi user
- create cronjob on Slave as root user 
gadkarisid
