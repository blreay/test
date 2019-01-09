#!/bin/bash

typeset URLBASE=http://bej301738.cn.oracle.com:16001//paas/service/apaas/api/v1.1/apps
#typeset curlcmd="curl -v"
typeset curlcmd="curl "

#set -vx
${curlcmd} -X POST -H "Content-Type: application/json" -d '{"title":"TEST" , "description":"ContainerPoolManager" , "location":"BeiJing"}'  ${URLBASE}/dm1
echo $?

${curlcmd} -X POST   ${URLBASE}/dm1/appid1/start 
echo $?
${curlcmd} -X GET    ${URLBASE}/dm1/appid1
echo $?
${curlcmd} -X DELETE ${URLBASE}/dm1/appid1
echo $?
