#!/bin/bash

if [[ "$1" == "" ]]
then
    DATE=`date +%Y/%m/%d`
else
    DATE=$1
fi

hexo new iptyoung "[Summary] 입트영 $DATE"
