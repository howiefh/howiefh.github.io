#! /bin/bash
echo "start"
SHELL=$(readlink -f $0)
SHELL_FOLDER=$(dirname "$SHELL")
WORK_FOLDER=`pwd`
echo "SHELL_FOLDER: $SHELL_FOLDER"
echo "WORK_FOLDER: $WORK_FOLDER"
echo "$ cd \"$SHELL_FOLDER\""
cd "$SHELL_FOLDER"
MESSAGE=$1
cd themes/landscape-f
echo "$ cd themes/landscape-f"
BRANCH=`git rev-parse --abbrev-ref HEAD`
if [ $BRANCH != "master" ]; then
  echo "$ git checkout master"
  git checkout master
fi
echo "$ cd ../.."
cd ../..
echo "$ git add ."
git add .
echo "$ git commit -am \"$MESSAGE\""
git commit -am "$MESSAGE"
if [ $BRANCH != "master" ]; then
  echo "$ cd themes/landscape-f"
  cd themes/landscape-f
  echo "$ git checkout $BRANCH"
  git checkout $BRANCH
  echo "$ cd ../.."
  cd ../..
fi
echo "$ cd \"$WORK_FOLDER\""
cd "$WORK_FOLDER"
read -p "Press any key to continue." var
echo "done"

