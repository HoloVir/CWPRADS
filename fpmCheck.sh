#!/bin/bash

#get running fpm instances
runningPHP=$(systemctl --type=service | grep -oh "php-fpm.*.service");

echo "Running PHP-FPM Versions==========================================";

for i in $runningPHP; do echo $runningPHP;systemctl status $i |grep -oh "Active: .*";done;

echo "Error log locations===============================================";
#error log locations for further research
logLocations=$(find /usr/local/cwp/php*/var/log/php-fpm.log);
echo $logLocations;

echo "Latest error logs==================================================";

for i in $logLocations; do echo $i; cat -n $i | tail -5;echo "=================================================================";done

echo -e "\n\n\n";

read -p "Do you wish to restart the PHP FPM services? Y or N: " resVar;
#input case
if [[ "$resVar" == "Y" ]]; then
#do restart on running FPM services
for i in $runningPHP; do systemctl restart $runningPHP;echo $runningPHP "restarted";systemctl status $i |grep -oh "Active: .*";done

elif [[ "$resValue" = "N" ]]; then

echo "No restart will occur on services. Exiting.....";
exit;

else

#this happens when you don't use the cases right (use Y or N pls)

echo "No valid option selected. Exiting.....";
exit;

fi
