#!/bin/bash
# FTP monitor
# By skamasle - @skamasle | skamasle.com

sub=(sub1 subd2 sub3 )
dom=domain.tld
correo=mail@yourdomain.tld
port=21

# Function whit dual check, check server, if is off check it again in 30 seconds, this help to prevent false positives.
function check() {
nc -w 3 -z $1 $port
if [ $? = 1 ]; then
	sleep 30
	nc -w 3 -z  $1 $port
	if [ $? = 1 ]; then
		server=off
	fi
else
	server=on
fi
}
# Check all subdomains, create some lock files, this only send one mail when server is down
for ft in ${sub[@]}; do
	check ${ft}.${dom}
	if [ -e /tmp/${ft}-off ] && [ $server = "on" ] ; then
	# Here you can add notification to advice you when FTP come back, just add new mail -s etc like inline 33
		rm -f /tmp/${sub}-off
	fi
	if [ $server = "off" ] && [ ! -e /tmp/${ft}-off ] ; then
		touch /tmp/${ft}-off
		echo "***FTP ${ft}.${dom} IS OFF ***" | $MAIL -s "***********FTP server is DOWN in $ft ***********" $correo 
	fi
done
