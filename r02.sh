#!/bin/bash

cmd="ffmpeg -hwaccel cuda -r 15 -i rtsp://user01:1234@10.3.129.74:12100/stream2 -c copy -f segment -segment_time 3600 -segment_format mp4 -strftime 1 -r 15 /root/nvr/record/stream2-%Y%m%d_%H%M%S.mp4"
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
                sleep 10
        done
