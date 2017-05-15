#!/bin/sh

#Fetch Current Server Address for plex.tv
#DNS="$(dig plex.tv +short) $(dig @8.8.8.8 plex.tv +short) $(dig @209.244.0.3 plex.tv +short)"
logger "Starting Plex static route script..."
DNS1=$(nslookup plex.tv | awk -F "Address: " '{print $2}' | awk 'NF > 0')
#Google DNS lookup
DNS2=$(nslookup plex.tv 8.8.8.8 | awk -F "Address: " '{print $2}' | awk 'NF > 0')
DNS3=$(nslookup plex.tv 8.8.4.4 | awk -F "Address: " '{print $2}' | awk 'NF > 0')
#Level3.net DNS lookup
DNS4=$(nslookup plex.tv 209.244.0.3 | awk -F "Address: " '{print $2}' | awk 'NF > 0')
logger "Grabbing current ipaddresses from plex.tv"
DNS="$DNS1 $DNS2 $DNS3 $DNS4"
# d: echo $DNS
UNIQ_IP=$(echo "$DNS" | tr ' ' '\n' | sort -u | tr '\n' ' ')
# d: echo $UNIQ_IP
logger "Current registered ip addresses: $DNS"

for IP in $UNIQ_IP
do
        #Create localroute variable to see if route exists
        localroute=`/sbin/route -n get $IP | grep "destination: $IP" | awk 'NF > 0'`
        #Check if route exists
        # d: echo $localroute
        if [ -z "$localroute" ]
        then
                # Route doesn't exist, add route
                ADD=`/sbin/route -nv add $IP 10.0.0.1`
                echo $ADD
        else
                # Route exists
                echo "$IP exists"
        fi
done
logger "Plex static route script complete."
exit 0
