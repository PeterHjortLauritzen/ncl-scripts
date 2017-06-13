https://github.com/PeterHjortLauritzen/ncl-scripts.git

Git commands
============

- Get help:

git help command
   where command is { init, config, fetch, pull, ....}


- Setup and fetch repo:

mkdir src
cd src
git init
git config user.name "PeterHjortLauritzen"
git config --global user.name "PeterHjortLauritzen"
git fetch https://github.com/PeterHjortLauritzen/ncl-scripts.git
git pull https://github.com/PeterHjortLauritzen/ncl-scripts.git

- Add a new filename to repo:

git add filename
  where filename is some file to be added to the repo.

- Check status:

git status
git status -s

- Checkin all you files (locally):

git commit -a

- Push to master repo:

git push https://github.com/PeterHjortLauritzen/ncl-scripts.git
