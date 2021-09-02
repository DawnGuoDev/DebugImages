#!/bin/bash

# This script check the 'kube-dns' service and dns pods connection from pod

myip=$POD_IP
pod_name=$POD_NAME
kube_dns_service_name=${KUBE_DNS_SERVICE_NAME}
kube_dns_service_ip=${KUBE_DNS_SERVICE_IP}
kube_dns_endpoints_ips=${KUBE_DNS_ENDPOINTS_IPS}

# curl kube-dns.kube-system.svc
count=0
while [[ true ]]; do
    curl "$kube_dns_service_name:53" -k --connect-timeout 15 > /dev/null 2>&1
    error_code=`echo $?`
    if [ $error_code -ne 0 ] && [ $error_code -ne 52 ]; then
        count=$[${count}+1]
        if [[ ${count} -eq 4 ]]; then
            errMsg="✕ Curl from src:pod($pod_name) to dest:dns_service_domain($kube_dns_service_name:53) failed"
            echo $errMsg
            break
        fi
        sleep 2
    else
        errMsg="✔ Curl from src:pod($pod_name) to dest:dns_service_domain($kube_dns_service_name:53) succeeded"
        echo $errMsg
        break
    fi
done

# curl kube_dns_service_ip
count=0
while [[ true ]]; do
    curl "$kube_dns_service_ip:53" -k --connect-timeout 15 > /dev/null 2>&1
    error_code=`echo $?`
    if [ $error_code -ne 0 ] && [ $error_code -ne 52 ]; then
        count=$[${count}+1]
        if [[ ${count} -eq 4 ]]; then
            curl "$kube_dns_service_ip:53" -k --connect-timeout 15
            errMsg="✕ Curl from src:pod($pod_name) to dest:dns_service($kube_dns_service_ip:53) failed"
            echo $errMsg
            break
        fi
        sleep 2
    else
        errMsg="✔ Curl from src:pod($pod_name) to dest:dns_service($kube_dns_service_ip:53) succeeded"
        echo $errMsg
        break
    fi
done

# curl kube_dns_endpoint_ips
errMsg=""
for pod in `echo "$kube_dns_endpoints_ips"`
do
    count=0
    while [[ true ]]; do
        curl "$pod:53" -k --connect-timeout 15 > /dev/null 2>&1
        error_code=`echo $?`
        if [ $error_code -ne 0 ] && [ $error_code -ne 52 ]; then
            count=$[${count}+1]
            if [[ ${count} -eq 4 ]]; then
                curl "$pod:53" -k --connect-timeout 15
                errMsg="✕ Curl from src:pod($pod_name) to dest:dns_endpoint($pod:53) failed"
                echo $errMsg
                break
            fi
            sleep 2
        else
            errMsg="✔ Curl from src:pod($pod_name) to dest:dns_endpoint($pod:53) succeeded"
            echo $errMsg
            break
        fi
    done
done