#!/bin/bash
#Desicription:这是一个时序列监控平台Prometheus软件的启动脚本。
#Author:Mr.shi
#creation_time:2018-11-29
#version:0.0.1
#history:No

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/local/httpd/bin:/usr/local/nginx/bin:/root/bin
NAME=Prometheus
START_SCRIPT_PATH=/etc/init.d/
FILE_PATH=/opt/promethues/prometheus-2.5.0.linux-amd64
PROT=9090
FILE_CONFIG=prometheus.yml
CHECK_PROT=$(netstat -tunlp | grep $PROT)
CHECK_FILE=$(cd /opt/promethues/prometheus-2.5.0.linux-amd64 && ./promtool check config ./$FILE_CONFIG | grep -i success)
CHECK_PROCESSES=$(ps aux | grep prometheus)
#定义检查配置文件函数
function checkconfig () {
    cd $FILE_PATH
    if [[ -f ./prometheus ]];then
        if [[ -n $CHECK_FILE ]];then
            echo "config file exits and normal"
        else
            echo "config file not normal,please check $FILE_PATH the file $FILE_CONFIG"
            exit 6
        fi
    else 
        echo "config file not exits or error"
    fi
}
#定义服务启动函数
function start () {
    if [[ -n ${CHECK_CHECK_PROT} ]] && [[ -n ${CHECK_PROCESSES} ]];then
        echo -e "\033[42;30mPrometheus is running.............\033[0m"
    elif [[ -z ${CHECK_CHECK_PROT} ]];then
         cd ${FILE_PATH};nohup ./prometheus --config.file=./prometheus.yml &
         if [[ -n ${CHECK_PROT} ]];then
            echo -e "\033[42;30m`date +%Y-%m-%d_%T`:Prometheus already running............\033[0m" #2>&1 /var/log/prometheus_run.log
         else
            echo -e "\033[41;30m`date +%Y-%m-%d_%T`:Prometheus start Not success,please check.........\033[0m" #2>&1 /var/log/prometheus_run.log 
         fi       
    fi
}
#定义服务停止函数
function stop () {
    if [[ -z ${CHECK_PROT} ]] && [[ -z ${CHECK_PROCESSES} ]];then
	echo -e "\033[42;30mServer is Stop!\033[0m"
    elif [[ -z ${CHECK_PROT} ]] && [[ -n ${CHECK_PROCESSES} ]];then
        echo -e "\033[41;30mServer running not normal,please check.........\033[0m"
    elif [[ -n ${CHECK_PROT} ]] && [[ -n ${CHECK_PROCESSES} ]];then
        ps aux | grep prometheus | awk '{print $2}' | head -n 1 | xargs kill -9 && flag=0
	if [[ $flag -eq 0 ]];then
	    echo -e "\033[42;30m`date +%Y-%m-%d_%T`:Prometheus Server already stop!\033[0m" #2>&1 /var/log/prometheus_run.log
        else 
            echo -e "\033[41;30m`date +%Y-%m-%d_%T`:Prometheus Server stop faild\033[0m" #2>&1 /var/log/prometheus_run.log

        fi
    fi

}
#定义服务重启函数
############################################################################################################
case $1 in
"start")
    checkconfig
    start
;;
"stop")
    stop
;;
"restart")
    stop
    start
;;
*)
    echo "Uage:service prometheus start | stop | restart"
esac >> /var/log/prometheus_run.log
#Processes END
