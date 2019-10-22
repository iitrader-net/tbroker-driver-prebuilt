#!/bin/bash
# build only modules list in the list
ONLY=

# build from the module specified in
FROM=

# skip clean
NO_CLN=${NO_CLN:-0}

# skip checkout 
NO_CO=${NO_CO:-0}

# verbose on command output
V=${V:-0}

# verbose on command to execute
VV=${VV:-0}

wdir=${wdir:-.}
start=

function action
{
	local name=$1
	shift 
	if [ "$VV" == 1 ]; then
		echo "$@"
	fi
	if [ "$V" == 1 ]; then
		if ! eval "$@" 2>&1 ; then
			return 1
		fi
	else
		if ! eval "$@" > ${wdir}/.$name.log 2>&1 ; then
			tail -n 160 ${wdir}/.$name.log 
			return 1
		fi
	fi
}

match=
function has_module
{
	local name="$1"
	local ONLY="$2"
	
	match=0
	if [ "${ONLY}" != "" ];  then
		for m in ${ONLY}; do
			if [ "$m" == "$name" ]; then
				match=1
			fi
		done
	else
		match=1
	fi
}

function out_git
{
	local name=$1
	local url=$2
	local tag=$3
	if [ "${start}" == "" ] && [ "${FROM}" != "" ] && [ "${FROM}" != "${name}" ] ; then
		return
	fi
	start=1
	has_module $name "$ONLY"
	if [ "$match" == "0" ]; then
		return
	fi
	if [ "$NO_CO" == "1" ]; then
		return
	fi

	export wdir=`pwd` 
	printf "[%15s]->[%10s] [%6s]\n" ${url} ${name} ${tag}
	cd ../

	if ! [ -d $name ]; then
		git clone ${url}${name}
	fi
	cd $name
	action $name "git fetch origin" || exit 1
	action $name "git checkout $tag" || exit 1
	cd $wdir 
}

function add_mod
{
	local name=$1
	shift
	if [ "${start}" == "" ] && [ "${FROM}" != "" ] && [ "${FROM}" != "${name}" ] ; then
		return
	fi
	start=1

	has_module $name "$ONLY"
	if [ "$match" == "0" ]; then
		return
	fi
	wdir=`pwd` 
	cd ../
	cd ${name} || exit 1
	if [ "${NO_CLN}" != "1" ]; then
		printf "[%15s]\t%s \n" ${name} "external.build"
		action $name "make clean"
	fi
	printf "[%15s]\t%s\n" ${name} "external.pack"

	action $name "make all" "$@" || exit 1
	action $name "make install " "$@"
	cd ${wdir}
}

function add_cmd
{
	local name=$1
	local target=$2
	shift
	shift
	if [ "${start}" == "" ] && [ "${FROM}" != "" ] && [ "${FROM}" != "${name}" ] ; then
		return
	fi
	start=1

	has_module $name "$ONLY"
	if [ "$match" == "0" ]; then
		return
	fi
	wdir=`pwd` 
	cd ../
	cd ${name} || exit 1
	printf "[%15s]\t%s \n" ${name} "$target"
	action $name "$target" || exit 1
	cd ${wdir}
}

