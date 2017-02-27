#! /bin/bash
#cu_ou_cnt=$1
cu_user_cnt=$2
cu_pass=123
#cu_ou_user_cnt=$[cu_ou_cnt*cu_user_cnt]
cu_ou_user_cnt=200000
cu_org_id=eduqc.rd.mt
cu_org_cnt=$1
cu_domain_id=mortest

tmpfile=$$.fifo        #创建管道名称
mkfifo $tmpfile       #创建管道
exec 4<>$tmpfile   #创建文件标示4，以读写方式操作管道$tmpfile
rm $tmpfile            #将创建的管道文件清除
thread=8            #指定并发个数
# 为并发线程创建相应个数的占位
{
for (( i=1;i<=$thread;i++ ))
do
echo;                  #因为read命令一次读取一行，一个echo默认输出一个换行符，所以为每个线程输出一个占位换行
done
} >&4                #将占位信息写入管道


date
echo "Create $cu_org_cnt orgs"
i=0
while [ $i -lt $cu_org_cnt ]
do

/home/coremail/bin/sautil -add d domain_name=$cu_domain_id$i.com
/home/coremail/bin/sautil -add o org_id=$cu_org_id\_$i\&org_name=$cu_org_id\_$i\&cos_id=1\&num_of_classes=$cu_ou_user_cnt
/home/coremail/bin/sautil -add ad org_id=$cu_org_id\_$i\&domain_name=$cu_domain_id$i.com
#/home/coremail/bin/sautil -add oc org_id=$cu_org_id\&cos_id=1\&num_of_classes=$cu_ou_user_cnt
#/home/coremail/bin/sautil -add ou org_id=$cu_org_id\&org_unit_id=test$i\&org_unit_name=test$i

i=`expr $i + 1`
done

echo "Create $cu_ou_user_cnt users"
i=0
while [ $i -lt $cu_org_cnt ]
do
j=0
while [ $j -lt $cu_user_cnt ]
do
read -u4
user=$j
echo u$user@$cu_domain_id
(sudo -u coremail /home/coremail/bin/userutil --create-user u$user@$cu_domain_id$i.com org_id=$cu_org_id\_$i\&cos_id=1\&password=$cu_pass ; echo>&4)&
j=`expr $j + 1`
done
i=`expr $i + 1`
done
date
