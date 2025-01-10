#!/bin/bash

set -ex

__log_file=/home/ubuntu/applications/github-backup/head-backup/github-head-backup.log
DATE=$(date +%m%d%Y)
__timestamp=$(date +"%D %T %Z")

echo -e "\n############################ $HOSTNAME - $__timestamp ############################\n" 2>&1 | tee -a $__log_file

cd $(dirname $0)
mkdir -p ${DATE}-head
cd ${DATE}-head

name="FLARE-forecast"
cntx="orgs"
page=1

/usr/bin/curl -H "Authorization: token ghp_XXX" "https://api.github.com/$cntx/$name/repos?page=$page&per_page=100" | grep -e 'clone_url*' | cut -d \" -f 4 | xargs -L1 git clone --depth=1 --no-single-branch 2>&1 | tee -a $__log_file

cd ..
/bin/tar -czvf ${DATE}-head.tar.gz ${DATE}-head 2>&1 | tee -a $__log_file

#rm -rf ${DATE}-head

/usr/bin/aws glacier upload-archive --account-id - --vault-name FLARE --body ${DATE}-head.tar.gz 2>&1 | tee -a $__log_file

rm -rf ${DATE}-head.tar.gz
