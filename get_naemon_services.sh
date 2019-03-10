#!/bin/bash

# Based on: https://exchange.nagios.org/directory/Utilities/Nagios-Central-add-hosts-%28nsca%29/details
# Modified by Kryssar & WebFooL , 2018-08-13
# Output in .cfg file still looks like crap, but it's a work in progress. 

# ToDo:
# Verify the checks (file exists, found host in log and so on 
# Verify that it works for several use cases and grabs any unknown host 
# Rewrite the whole thing ? 

# Template
# the script only generates rudimentary host
# information. To make them work a host template for
# the generated hosts must be included into the
# naemon configuration. The names of the templates are set
# in the configuration of the this script (see below).
# You can use the following example templates.
#  
# define host{
#        name                            generic-autodiscover-host
#        notifications_enabled           1
#        event_handler_enabled           1
#        flap_detection_enabled          1
#        failure_prediction_enabled      1
#        process_perf_data               1
#        retain_status_information       1
#        retain_nonstatus_information    1
#        check_command                   check-host-alive
#        max_check_attempts              10
#        check_period                    24x7
#        notification_interval           120
#        notification_options            d,u,r
#        notification_period             24x7
#        contact_groups                  admins
#        active_checks_enabled           0
#        passive_checks_enabled          1
#        host_groups                     autodiscover
#        register                        0
# }
# 

#############
# variables #
#############
        workdir=/etc/naemon/conf.d
        naemonlog=/var/log/naemon/naemon.log
        naemondir=/etc/naemon/conf.d

                # ROUTINE FOR CHECK
                # Missing IP Address So we can add "address 192.168.x.x"
                # IP will not be in the Naemon.log so we need to add some logic to try to ping $item and collect ip from there
                # For that to work the DNS need to be uptodate with all hosts.
                        function process_hostresult {
                                        #$ipaddress = ping -c1 $item | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p'
                                        $ipaddress = dig +short $item
                                        echo "add host" $item
                                        echo "define host{"  > $workdir/$Unknownhost.cfg
                                        echo "host_name  $item" >> $workdir/$Unknownhost.cfg
                                        echo "alias $Unknownhost-autodiscover"  >> $workdir/$Unknownhost.cfg
                                        if [ -n "$ipaddress" ]; then
                                         echo "address $ipaddress"  >> $workdir/$Unknownhost.cfg
                                        fi
                                        echo "use autodiscover"  >> $workdir/$Unknownhost.cfg
                                        echo "}"  >> $workdir/$Unknownhost.cfg
                                        sleep 3
                                }

###################################
# Searching log for unknown hosts #
###################################

echo "starting"
while true
        do
        echo "searching "$naemonlog" for unknown hosts..."
        sleep 3
        #for item in $(grep "host could not be found" "$nagioslog" | awk -F ' ' '{print $13}' | sed s/[\',]//g | grep -v Status | grep -v host | grep -v gebruik | grep -v on | grep -v CAG | grep -v nagioscentral)
        #for item in $(tail -n 100 "$nagioslog" | grep "host could not be found" | awk -F ' ' '{print $13}' | sed s/[\',]//g | grep -v Status | grep -v host | grep -v gebruik | grep -v on | grep -v CAG | grep -v nagioscentral)
        for item in $(cat /var/log/naemon/naemon.log | grep "Failed validation" | cut -d ';' -f 2 | grep -v External | uniq)
        do
        echo host found: "$item"
        sleep 3


                # declaration customer for use of template
                #Unknownhost=`echo $item | sed s/-.*//g`
                Unknownhost=$item

# check if customer.cfg excists
if [ -f "$workdir/$Unknownhost.cfg" ] ;
        then
        echo config file "$Unknownhost" exists for host "$item"
        sleep 3

				# check if host already exists
                if grep -q $item $workdir/$Unknownhost.cfg
                        then
                        echo "host $item already exists not adding..."
                        sleep 3

                else
                echo "$item" not found in cfg files
                #process_hostresult()
                sleep 3
                fi


# if not exist, touch customer.cfg in workdir
else
        echo "creating $Unknownhost.cfg"
        touch $workdir/$Unknownhost.cfg
        process_hostresult
        sleep 3

fi
done
echo end of script, restarting...
sleep 3
done 
