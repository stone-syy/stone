#!/bin/bash
#Program Desc:
#             这是一个收集省端USDP和GW日志,将其传回脚本所在机器的一个脚本。主机信息是脚本所在目录的host.txt文件
#             主机信息填写规则：远程主机的业务账号名:远程主机IP:远程主机Password
#Desc:主机文件为脚本路径下的host.txt.exp文件为脚本路径下的login_script.exp
#Version:1.0
#Author:Mr.shi
#history:
#        2018-12-18 编写
#        2018-12-19 第一次修改:1、加入音频USDP、GW日志路径变量。2、将host.txt文件改为4个字段。
#        2018-12-20 第二次修改:1、对音频、视频单独创建日志存放目录。2、更改获取日志逻辑为本机SCP拉取
#############################################################################################################
start=$(date +%s)
echo "************************"
echo "**Script starting.....**"
echo "************************"
#定义变量
sp_usdp_developer=/home/usdp/isap/logs/server/log/Developer/Developer.log
yp_usdp_developer=/home/usdp/usdpd61/logs/server/log/Developer/Developer.log
sp_usdp_runlog=/home/usdp/isap/logs/run/run.log
yp_usdp_runlog=/home/usdp/usdpd61/logs/run/run.log
sp_gw_developer=/home/rbtgw/iSAP/logs/server/log/Developer/Developer.log
yp_gw_developer=/home/gateway/isapRUN/logs/server/log/Developer/Developer.log
sp_gw_runlog=/home/rbtgw/iSAP/logs/server/log/rbtgw/rbtgw.log
yp_gw_runlog=/home/gateway/isapRUN/logs/server/log/rbtgw/rbtgw.log
base_dir=/home/weihu/jizhongcheckscript/check_script_005
#登录函数
function login() {
    /usr/bin/expect $base_dir/login_script.exp $1 $2 $3 $4 $5 $6 $7
    if [[ `echo $?` != 0 ]];then
        echo -e "\033[40;31m`date +%F-%T`:$3——connot connection the host\033[0m"
    else
        echo -e "\033[40;31m`date +%F-%T`:$3——connection succssful\033[0m"
    fi
}
#以当前日期创建一个usdp log目录
    if [[ -d `date +%F`_usdp_log ]];then
        echo "dirctory already exits"
    else
        mkdir -p `date +%F`_usdp_log/yp_usdp 
        mkdir -p `date +%F`_usdp_log/sp_usdp
    fi         
    if [[ -d `date +%F`_gw_log ]];then
        echo "dirctory already exits"
    else
        mkdir  -p `date +%F`_gw_log/yp_gw
        mkdir  -p `date +%F`_gw_log/sp_gw
    fi
usdp_log=`date +%F`_usdp_log
gw_log=`date +%F`_gw_log
yp_usdp_log=${usdp_log}/yp_usdp
sp_usdp_log=${usdp_log}/sp_usdp
yp_gw_log=${gw_log}/yp_gw
sp_gw_log=${gw_log}/sp_gw
#检查磁盘空间函数
function check_dev() {
   for check_host in `cat check.txt`;do
       check_type=$(echo check_host | cut -d: -f1)
       check_addr=$(echo check_host | cut -d: -f3)
       check_user=$(echo check_host | cut -d: -f2)
       check_pass=$(echo check_host | cut -d: -f4)
       for host in ${check_host};do
           ssh ${check_user}@${check_addr}
           check_login $1 $2 $3
           df -h | awk '{print $5}' | head -n 2 | tail -n 1 | cut -d% -f1
           check_data=$(df -h | awk '{print $5}' | head -n 2 | tail -n 1 | cut -d% -f1)
           if [[ ${check_data} -ge 85 ]];then
               echo "`date +%F_%T`:${check_host}:磁盘空间快满了，请检查" >> check.log
           fi
       done
done
}
#eixt函数
function exit_now() {
    if [[ `echo $?` != 0 ]];then
        echo "`date +%F_%T`:Failed to transfer file...........,please check reason."
    else 
        echo "`date +%F_%T`:succssful to transfer file."
        logout
    fi
}
#逐行读取主机信息
grep -v "^#" host.txt | while read host;do
      host_type=$(echo $host | cut -d: -f1)
      user=$(echo $host | cut -d: -f2)
      ip=$(echo $host | cut -d: -f3)
      pass=$(echo $host | cut -d: -f4)
#判断主机类型，从而到对应目录下获取日志
    case ${host_type} in
        sp_usdp)
        login ${user} ${ip} ${pass} ${sp_usdp_developer} ${sp_usdp_runlog} ${base_dir} ${sp_usdp_log}
    ;;
        yp_usdp)
        login ${user} ${ip} ${pass} ${yp_usdp_developer} ${yp_usdp_runlog} ${base_dir} ${yp_usdp_log}
    ;;
        sp_gw)
        login ${user} ${ip} ${pass} ${sp_gw_developer} ${sp_gw_runlog} ${base_dir} ${sp_gw_log}
    ;;
        yp_gw)
        login ${user} ${ip} ${pass} ${yp_gw_developer} ${yp_gw_runlog} ${base_dir} ${yp_gw_log}
    ;;
        *)
        echo "not found host type,please check host.txt"
    esac >> run.log
done
#脚本结束
echo -e "*************************"
echo -e "**Script End...........**"
echo -e "*************************"
end=$(date +%s)
runtime=$(($end-$start))
echo "Script rum time is ${runtime}s"
