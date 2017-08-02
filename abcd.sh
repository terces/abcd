#!/bin/sh
#
# Copyright (C) 2014-2017 Arcadyan
# All Rights Reserved.
#

# Author: Terces Tsai @ ARCADYAN
# abcd: Automation build and continuous delivery

# repo		none					pre
# destdir	/var/run/abcd/			run
# log		$(`basename $PWD`).log	post
# mailto	file

SELF=`/usr/bin/basename $0`
GIT="/usr/bin/git"

REPO=""
DEST="/var/run/abcd/"
LOG=""
RCPT=""

PREPARE_SCRIPT=""
COMPILE_SCRIPT=""
POSTING_SCRIPT=""

echo $SELF

usage () {

}

main () {
	# initail, parse parameter

}

main
