#Install nmap, mailx, sendmail and postfix
#Ensure to define the parent directory in the PDIR variable
PDIR=/home/barasst/test
flog=$PDIR/rogue_ip_scanner.log #Script log file
bdir=$PDIR/backups
nip=$PDIR/network_range.txt
DHXF=$PDIR/rogue_ip_scanner.xml #Nmap scan XML output file
DHIP=$PDIR/Detected_host_ips_$(date "+%Y.%m.%d").txt
EHIP=$PDIR/existing_host_IP.txt
NDHIP=$PDIR/new_ips_detected_$(date "+%Y.%m.%d").txt
BNDHIP=$bdir/new_ips_detected_$(date "+%Y.%m.%d").txt #Newly detected Host file located in the backup folder
BDHIP=$bdir/Detected_host_ips_detected_$(date "+%Y.%m.%d").txt #Host file of detected hosts located in the backup folder
raddr=$PDIR/email_address_list.txt #Manually create this.


if [ ! -d "$bdir" ]
then 
mkdir $bdir
echo "$(date) The directory $bdir Created!" >> $flog 
else
echo "$(date) The directory $bdir exists!" >> $flog
fi

#***Host Scanning ***
echo "$(date) Nmap scan started..." >> $flog
nmap -sn -iL $nip -oX $DHXF  # Modified Nmap command for port scanning and OS detection
#nmap -sS -p1-65535 -O -iL $nip -oX $DHXF  # Modified Nmap command for port scanning and OS detection
echo "$(date) Nmap scan ended" >> $flog

#***IP Extraction ***
if [ $(grep 'hosts.up="0"' $DHXF | wc -l) -eq 0 ]; then
    echo "$(date) Extracting IPs from $DHXF" >> $flog
    grep -Eo "(([0-9]{1,3}\.){3}[0-9]{1,3})" $DHXF | uniq > $DHIP  # Extracting IPs or unique IPs that were up
    echo "$(date) Extraction ended" >> $flog
else
    echo "$(date) No host detected" >> $flog
    exit
fi

#***IP Comparison ***
###***Comparing newly detected IPs with existing detected IPs to detect new IPs

ips=$(cat $DHIP | tr -s '\n' ' ')
for n in $ips; do
    var1="$(grep -w "$n" $DHIP)"
    var2="$(grep "$n" $EHIP)"

    if [ "$var1" = "$var2" ]; then
        echo "$(date) The Device $n exists on $EHIP " >> $flog
    else
        echo "$n" >> $NDHIP #Newly detected IPs output
        echo "$(date) New host IP $n detected!" >> $flog
    fi
done

#Sending of an Email

###***Checking if the Newly detected device file exists and has data
if [ -f ${NDHIP} ]
then
       echo "$(date) Copying the $NDHIP to the $bdir directory" >> $flog
       cp  $NDHIP $BNDHIP
sleep 30
       echo "$(date) Copying the $NDHIP to the $bdir directory done!" >> $flog
       echo "$(date) $NDHIP exists proceeding to send an email" >> $flog
sed -i "1s/^/Kindly receive the attached New Detected Device report for $(date) \n/" $NDHIP
echo "Regards" >> $NDHIP

echo "$(date) sending mail ..." >> $flog

cat $NDHIP | mail -s "New Detected Device Report For $(date)" $(cat $raddr | tr -s '\n' ' ' ) #sending email with csv attacment to recipients
echo "$(date) Email sent to $raddr successfully!" >> $flog

#Move the zipped file to the backup directory
echo "$(date) Removing $NDHIP file..." >> $flog
rm $NDHIP
echo "$(date) Removing $NDHIP file done!" >> $flog
    else
	echo "The $NDHIP File does not  exist" >> $flog
    fi
echo "$(date) Moving $DHIP file..." >> $flog
mv $DHIP $BDHIP
echo "$(date) Moving $DHIP file done!" >> $flog

#Removing Junk files
echo "$(date) removing $DHXF file..." >> $flog
rm $DHXF
echo "$(date) removing $DHXF file done!" >> $flog
echo "$(date) Script exiting..." >> $flog
exit
