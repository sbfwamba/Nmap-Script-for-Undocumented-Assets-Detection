# Nmap-Script-for-Undocumented-Assets-Detection
This script is used to automate process of detecting new assets added to the network and they not been documented.
Install nmap, mailx.
Create the existing IP file
Create the recipient email address file and insert all required email addresses.
Create the network range file and add the networks or subnets to be scanned.

How it works
The script will create a backup directory at the start. This directory is used to store all old reports.
Then the nmap will start scanning the networks defined under network range and output the results in the xml format.
Another command will extract any IPv4 IPs on then file. If none is found the script will terminate.
Once done with the extraction, another command will compare the IPs on the detected  text file and the existing IPs file.
If new hosts have been detected, they will put will be done on a new text file which will be send to the email added.
You can modify the script to your preference.
