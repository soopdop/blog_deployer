#!/bin/bash

if [[ "$1" == "" ]]
then
    DATE=`date +%Y/%m/%d`
else
    DATE=$1
fi

hexo new kwajang "[Summary] 김과장 비즈니스 영어로 날다 $DATE"
