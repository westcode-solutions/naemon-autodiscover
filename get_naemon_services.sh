#!/bin/bash

if [ -f /tmp/naemon_list ]; then
        rm -f /tmp/naemon_list
else
        touch /tmp/naemon_list
fi

for server in $(cat /var/log/naemon/naemon.log | grep PROCESS_SERVICE | cut -d';' -f 2 | uniq); do
        service=$(cat /var/log/naemon/naemon.log | grep $server | cut -d';' -f 3 | uniq)
        echo "hostname:$server;service:$service" >> /tmp/naemon_list
done

if [ -f /tmp/new_naemon_services ]; then
        rm -f /tmp/new_naemon_services
else
        touch /tmp/new_naemon_services
fi

cat /tmp/naemon_list | sort -n | uniq >> /tmp/new_naemon_services

echo " :: New services found :: "
cat /tmp/new_naemon_services
#cat /tmp/new_naemon_services | cut -d';' -f 2
