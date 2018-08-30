#!/bin/bash

if [[ "$1" == "" ]]
then
    DATE=`date +%Y/%m/%d`
else
    DATE=$1
fi

hexo new iptyoung "[Note] 입트영 $DATE"
