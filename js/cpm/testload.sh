#!/bin/bash

typeset URLBASE=http://bej301738.cn.oracle.com:16001//paas/service/apaas/api/v1.1/apps
typeset curlcmd="curl -v"
#typeset curlcmd="curl "

${curlcmd} -X POST ${URLBASE}/dm1/testload
#${curlcmd} -X POST ${URLBASE}/dm1/appid1/start
#${curlcmd} -X DELETE ${URLBASE}/dm1/appid1
