#!/bin/bash
# APC information capture script 2023 v2

# variables
TERM=vt100
export TERM
tmpfile=/home/zabbix/apc_capture.tmp
serialport="/dev/ttyS0"
serveraddress="your zabbix server address"

# function for send data to Zabbix server
function sendparam() {
	/home/zabbix/bin/zabbix_sender -z $serveraddress -s "APC SmartUPS RT3000" -k $1 -o $2
}

# remove old capture file
rm -rf $tmpfile 

# get the data from serial port
/usr/bin/expect -c "
	spawn /usr/bin/minicom --capturefile=$tmpfile;
	expect \"шам\";
	send \"\r\";
    expect \">\";
    send \"\u001b\";
";

pkill minicom
# write data to variables and send to Zabbix server
upsbrt=$(cat $tmpfile | grep "Battery Run Time" | awk {'print $5'} | awk 'BEGIN{FS=OFS=":"} NF--') && sendparam ups.brt $upsbrt 
upsrc=$(cat $tmpfile | grep "Remaining Capacity" | awk {'print $3'} | sed 's/%//') && sendparam ups.rc $upsrc  
upsbv=$(cat $tmpfile | grep "Battery Voltage" | awk {'print $4'} | sed 's/V//') && sendparam ups.bv $upsbv 
upsbt=$(cat $tmpfile | grep "Battery Temperature" | awk {'print $3'} | sed 's/C//') && sendparam ups.bt $upsbt 
upsiv=$(cat $tmpfile | grep "Input Voltage" | awk {'print $4'} | sed 's/VAC//') && sendparam ups.iv $upsiv 
upsliw=$(cat $tmpfile | grep "Load in Watts" | awk {'print $10'} | sed 's/%,//') && sendparam ups.liw $upsliw 
exit

