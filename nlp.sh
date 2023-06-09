#!/bin/bash

Help()
{
   # Display Help
   echo "Usage: nlp function gets information related to domain from CWP Apache Domlogs such as largest number of requests, top IPs, top IPs with PTR records, and user agents."
   echo
   echo "Syntax: nlp domain.tld"
   echo "options:"
   echo "h     Print this Help."
   echo
}


while getopts ":h" option; do
   case $option in
      h) # display Help
         Help
         exit;;
		  \?) # incorrect option
         echo "Error: Invalid option"
         exit;;
   esac
done

if [ -z "$1" ]; then echo "No args, please use 'nlp domain.tld' or nlp -h for help"; exit;fi;
 
#Date operator to get records from last 24 -48 hours

getDate=$(date -d Yesterday +"%d/%b/20%y");


getToday=$(date -d Today +"%d/%b/20%y");

#get domain input and find log file, args passed via command. Ex: nlp domain.tld

domain="$1";

#sanity check. Does the input have logs on the system? If not then exit.
if [ -f "/usr/local/apache/domlogs/$domain.log" ]; 
then
echo -n "";
else
echo "No records for $domain exist on this server. Exiting....";
exit;
fi;

#case for log range
read -p "Would you like records for [Y]esterday or [T]oday: (Please use Y or T)" dateValue;

if [[ "$dateValue" == "T" ]]; then

#get logs and print in cozy format
cat /usr/local/apache/domlogs/$domain.log |grep -i $getToday | grep -E -oh 'GET .* [12345][01235][0-9] [[:digit:]]{1,8} |POST .* [12345][01235][0-9] [[:digit:]]{1,8} ' | sed -r 's/\ b(GET|HTTP)\b//g' | sort | uniq -c | sort -nr | awk '{$6=""; print $0}'| head -10;
echo "Top User Agents ==================================================================================================================="
cat /usr/local/apache/domlogs/$domain.log |grep -i $getToday | grep -oh '"-".*'| sort | uniq -c | sort -nr | head -10
elif [[ "$dateValue" = "Y" ]]; then

cat /usr/local/apache/domlogs/$domain.log | grep -E -oh 'GET .* [12345][01235][0-9] [[:digit:]]{1,8} |POST .* [12345][01235][0-9] [[:digit:]]{1,8} ' | sed -r 's/\ b(GET|HTTP)\b//g' | sort | uniq -c | sort -nr | awk '{$6=""; print $0}'| head -10;
echo "Top User Agents =================================================================================================================="
cat /usr/local/apache/domlogs/$domain.log |grep -i $getDate | grep -oh '"-".*'| sort | uniq -c | sort -nr | head -10
else

#this happens when you don't use the cases right (use Y or T pls)

echo "No valid option selected. Exiting.....";
exit;

fi

echo "Laregest Connections that you may want to consider reducing if affecting performance:===================================";

cat /usr/local/apache/domlogs/$domain.log | grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | tr " " "\n"|sort -nk1| uniq -c |sort -nr | head -10;

echo "Top IPs with PTR record:====================================================================================================";
ipLookup=$(cat /usr/local/apache/domlogs/$domain.log | grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | tr " " "\n"|sort -nk1| uniq -c |sort -nr| awk '{print $2}'|head -10);
for i in $ipLookup; do digVal=$(dig +short -x $i); if [[ -n $digVal ]];then echo "IP: $i Hostname: $digVal";else echo -n "";fi;done;
ipForHost=$(hostname -i)
echo "Script generated deny list that can be put in a .htaccess file.==========================================================";
declare -a biggestConns;mapfile -t biggestConns < <(sudo cat /usr/local/apache/domlogs/$domain.log | grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | tr " " "\n"|sort -nk1| uniq -c | sort -nr | awk '{print $2}'|sed "s/$(hostname -i)//g"| sed '/^$/d');upperLimit=$(echo ${#biggestConns[@]}); start=0;for i in {0..10};do echo "deny from" ${biggestConns[$i]};done;echo "Please note that the host IP for this server is $ipForHost and hostname is $(hostname)" ;
