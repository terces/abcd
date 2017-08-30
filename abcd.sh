#!/bin/sh
#
# Copyright (C) 2014-2017 Arcadyan
# All Rights Reserved.
#

# Author: Terces Tsai @ ARCADYAN
# abcd: Automation build and continuous delivery

# destdir	/var/run/abcd/			pre
# log		$(`basename $PWD`).log	run
# mailto	file					after

SELF=`/usr/bin/basename $0`
HOST=`/bin/hostname`

GIT="/usr/bin/git"
MAIL="/bin/mail"

PROJ=""
DEST="/var/run/abcd/"
LOG=""
RCPT=""

PREPARE_SCRIPT=""
COMPILE_SCRIPT=""
AFTWARD_SCRIPT=""

function usage () {

	echo "$SELF - Automation Build and Continuous Delivery"
	echo "Usage:"
	echo "	$SELF -d codebase_dir -l logfile -m mailto [-h]"
	echo "	-p prepare_script -r compile_script -a post_processing_script"
	echo "Notice:"
	echo "	destination directory will need absolute path"
	echo "Example:"
	echo "	$SELF -d $PWD -m reciever"
	echo "	-p fetch.sh -r run.sh -a post.sh"
	exit -1
}

function main () {
	BUILD_ROOT=$PWD
	#initial script, must contain `PROJ`, `GIT_DIR`, and `GIT_WORK_TREE`
	if [ ! -z $PREPARE_SCRIPT ]; then
		source $PREPARE_SCRIPT $DEST
	fi
	#initial logging file filename if not assigned
	if [ -z $LOG ]; then
		LOG=$PROJ-`/bin/date +"%Y%m%d%H"`.log
	fi
	#compile script, must contain `RET_CODE` and make compile log
	if [ ! -z $COMPILE_SCRIPT ]; then
		source $COMPILE_SCRIPT $LOG
	fi
	if [ $RET_CODE -eq 99 ]; then
		echo "SKIP COMPILATION FOR REASONS: no commits"
		return ;
	fi
	#afterwards script, must contain `COMPLETE`
	if [ ! -z $AFTWARD_SCRIPT ]; then
		source $AFTWARD_SCRIPT
	else
		COMPLETE=-1
	fi

	if [ ! -z $RCPT ]; then
		if [ $COMPLETE -ge 0 ]; then
			/bin/mail -s "[AB&CD] $PROJ compiled successful!" `/bin/cat $RCPT` << _EOT
This is buildbot@$HOST
The project "$PROJ" has fully compiled with the latest commit.
Last 24 hours changes:
===
`$GIT --git-dir=$GIT_DIR --work-tree=$GIT_WORK_TREE log --date=short --format="[%h]%ad.%aN: %s" --since="24 hours ago"`
===
_EOT
		else
			/bin/mail -s "[AB&CD] $PROJ compiled failed!" `/bin/cat $RCPT` << _EOT
This is buildbot@$HOST
The project "$PROJ" compiled failed with the latest commit.
Last 24 hours changes:
===
`$GIT --git-dir=$GIT_DIR --work-tree=$GIT_WORK_TREE log --date=short --format="[%h]%ad.%aN: %s" --since="24 hours ago"`
===
and the failed build log:
===
`/usr/bin/tail -n 80 $GIT_WORK_TREE/$LOG`
===
_EOT
		fi
	fi
}

while getopts "d:m:l:p:r:a:h" opt; do
	case $opt in
		d) DEST=$OPTARG;;
		m) RCPT=$OPTARG;;
		l) LOG=$OPTARG;;
		p) PREPARE_SCRIPT=$OPTARG;;
		r) COMPILE_SCRIPT=$OPTARG;;
		a) AFTWARD_SCRIPT=$OPTARG;;
		h) usage ;;
		\?)
			echo "Invalid Option: -- $OPTARG"
			usage
			;;
		:)
			echo "Option -$OPTARG requires argument."
			usage
			;;
	esac
done

main
