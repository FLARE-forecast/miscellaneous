#!/bin/bash

set -ex

__log_file=/home/ubuntu/applications/github-backup/full-backup/github-full-backup.log
DATE=$(date +%m%d%Y)
__timestamp=$(date +"%D %T %Z")

echo -e "\n############################ $HOSTNAME - $__timestamp ############################\n" 2>&1 | tee -a $__log_file

cd $(dirname $0)
mkdir -p ${DATE}-full
cd ${DATE}-full

name="FLARE-forecast"
cntx="orgs"
page=1

/usr/bin/curl -H "Authorization: token ghp_XXX" "https://api.github.com/$cntx/$name/repos?page=$page&per_page=100" | grep -e 'clone_url*' | cut -d \" -f 4 | xargs -L1 git clone 2>&1 | tee -a $__log_file

rm -rf ../../head-backup/*-full

mv ../${DATE}-full ../../head-backup/.
