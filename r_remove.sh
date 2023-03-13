#!/bin/bash

cmd="find /root/nvr/record/ -mtime +30 -type f -delete"
cmdback="${cmd} &"
echo $cmd
echo $cmdback
while [ 1 ]
        do
                pid=`ps -ef | grep "$cmd" | grep -v 'grep' | awk '{print $2}'`
                echo $pid
                if [ -z $pid ];then
                        echo "!restart!"
                        date
                        eval $cmdback
                fi
                sleep 360
        done
