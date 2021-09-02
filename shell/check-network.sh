#!/usr/bin/env bash

myip=$POD_IP
pod_name=$POD_NAME
###################################################
# check pod ping nodes
errMsg=""
for node_ip in $(echo ${NODE_IP_LIST})
do
    # L3 network
    count=0
    while [[ true ]]; do
        ping -c 1 $node_ip >> /dev/null
        if [ `echo $?` -eq 0 ]; then
             echo "✔ Ping from src:pod($pod_name) to dest:node($node_ip) succeeded"
            break
        else
            count=$[${count}+1]
            if [[ ${count} -eq 2 ]]; then
                errMsg=$errMsg";Ping from src:pod($pod_name) to dest:node($node_ip) failed."
                echo "✕ "$errMsg
                break
            fi
            sleep 1
        fi
    done
done

###################################################
# check pod ping pods
errMsg=""
for pod_ip in $(echo ${POD_IP_LIST})
do
    if [[ "$pod_ip" != "$myip" ]]; then
        count=0
        while [[ true ]]; do
            ping -c 1 $pod_ip >> /dev/null
            if [ `echo $?` -eq 0 ]; then
                echo "✔ Ping from src:pod($pod_name) to dest:pod($pod_ip) succeeded"
                break
            else
                count=$[${count}+1]
                if [[ ${count} -eq 2 ]]; then
                    #ping -c 1 $pod_ip
                    errMsg=$errMsg";Ping from src:pod($pod_name) to dest:pod($pod_ip) failed"
                    echo "✕ "$errMsg
                    break
                fi
                sleep 1
            fi
        done
    fi
done



