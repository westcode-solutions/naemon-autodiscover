#/!bin/bash

for item in $(cat naemon.log | grep "command parse error" | cut -d ';' -f 2-3 | uniq); do
	hostname=$(echo $item | cut -d ';' -f 1)
	service=$(echo $item | cut -d ';' -f 2)
	echo "hostname: " $hostname 
	echo "service: " $service
done
