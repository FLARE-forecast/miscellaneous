Here is some note for the future:
# Purpose for the `git-push-exp`
This is an experimental sh for do test on the new approach for mia. 

To create a bare local worktree as remote repository, do below script on the server machine
```sh
mkdir /data/fcre-data-exp-remote.git
cd /data/fcre-data-exp-remote.git
git init --bare
```

Then clone it to anywhere else, e.g. a client machine or another folder on the server
```sh
git clone /data/fcre-data-exp-remote.git #for the server machine
git clone ubuntu@server:/data/fcre-data-exp-remote.git # for the client machine
```
Initialize it with a main branch
```sh
echo "test" > file.txt
git add file.txt
git commit -m "initial commit"
# rename branch:
git branch -m main
git push -u origin main
```