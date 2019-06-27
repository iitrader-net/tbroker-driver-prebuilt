#!/bin/bash
D=$0
D=${D%/*}
eval $@
source $D/m-int.sh
rm -rf ../jlib/*

repo=${repo:-gitadm@qr2s.com:}

out_git tbroker ${repo}${tboker} master 
add_cmd tbroker "gradle build"

cp ../tbroker/build/libs/tbroker-1.0-all.jar ../jlib/tbroker.jar

out_git tbroker-driver ${repo}${tboker} master
add_cmd tbroker-driver "ant clean"
add_cmd tbroker-driver "ant"

out_git tbroker-driver-sino ${repo}${tboker} master
add_cmd tbroker-driver-sino "ant clean"
add_cmd tbroker-driver-sino "ant"

#out_git tbroker-driver-cap ${repo}${tboker} cn
#add_cmd tbroker-driver-cap "ant clean"
#add_cmd tbroker-driver-cap "ant"

rm -rf blob/*
cp ../jlib/* blob
