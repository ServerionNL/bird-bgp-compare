#!/bin/bash  
# Birdc Script to check and compare sessions
# Serverion.com - 2022
## Setting Slack Vars
slack_url="https://hooks.slack.com/services/XXXXXXXXXX"

echo -e "BGP Update Script - \n"
now=$(date)
echo $now
echo -e "\n"

#mv -f /home/bgp/new4.txt /home/bgp/old4.txt
#mv -f /home/bgp/new6.txt /home/bgp/old6.txt

 echo $'1. Checking current BGP sessions IPv4...OK'
 sleep 1
 /usr/sbin/birdc -s /var/run/bird/bird-rs1-ipv4.ctl sh protocols | grep -i esta | awk -F '_' '{print $3}' | awk '{print $1" "$8}' | sed 's/as//'g > /home/bgp/new4.t>
 sleep 2

 echo $'2. Checking current BGP sessions IPv6...OK'
 sleep 1
 /usr/sbin/birdc -s /var/run/bird/bird-rs1-ipv6.ctl sh protocols | grep -i esta | awk -F '_' '{print $3}' | awk '{print $1" "$8}' | sed 's/as//'g > /home/bgp/new6.t>
 sleep 2

 echo "3. Comparing IPv4:" 
 sleep 1
 ## Compare files
 update=`grep -v -f /home/bgp/old4.txt /home/bgp/new4.txt`
 for ip4 in $update; do
    ## Grab Whois information from radb if available
    name=`whois -h whois.radb.net as$ip4 | grep descr | awk -F ' ' '{print $2}' | uniq`
    slack_text="$name AS: $ip4"
    slack_action=${2}
        ## Slack function
        function slackalert () {
        slack_title="AS$ip4 - $name IPv4 BGP Session is UP!"
        local slack_payload="{\"attachments\": [ { \"title\": \"${slack_title}\", \"text\": \"${slack_text}\",  \"color\": \"${slack_color}\" } ] }"
         curl --connect-timeout 30 --max-time 60 -s -S -X POST -H 'Content-type: application/json' --data "${slack_payload}" "${slack_url}"     
         }
        slackalert
        echo "$slack_title" | mail -s "AS$ip4 is online!" mail@mail.com -a From:BGP \<noc@mail.net\>
 done

echo "4. Comparing IPv6:"
 sleep 1
 update=`grep -v -f /home/bgp/old6.txt /home/bgp/new6.txt`
 for ip6 in $update; do
    ## Grab Whois information from radb if available
    name=`whois -h whois.radb.net as$ip6 | grep descr | awk -F ' ' '{print $2}' | uniq`
    slack_text="$name AS: $ip6"
    slack_action=${2}
        ## Slack function
        function slackalert () {
        slack_title="AS$ip6 - $name IPv6 BGP Session is UP!"
        local slack_payload="{\"attachments\": [ { \"title\": \"${slack_title}\", \"text\": \"${slack_text}\",  \"color\": \"${slack_color}\" } ] }"
         curl --connect-timeout 30 --max-time 60 -s -S -X POST -H 'Content-type: application/json' --data "${slack_payload}" "${slack_url}"     
         }
        slackalert
        echo "$slack_title" | mail -s "AS$ip4 is online!" mail@mail.com -a From:BGP \<noc@mail.net\>
 done



