#!/bin/bash

set -e
source vars.sh

while [ ! -z $1 ]
do
	if [ "--skip-src" = $1 ]
	then
		SKIP_SRC=1
	elif [ "--skip-cromite" = $1 ]
	then
		SKIP_CROMITE=1
	fi
	shift
done

if [ ! -d "depot_tools" ]
then
	echo "Downloading depot tools..."
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git depot_tools
fi

PATH=$PATH:$BASE_DIR/depot_tools

echo "Downloading source and patches..."

# Bromite
if [ $SKIP_CROMITE -eq 0 ] && [ ! -d "cromite" ]
then
	git clone $CROMITE_REPO cromite
else
	echo "Skipped cloning Bromite repo."
	echo
fi

cd cromite
git fetch origin $PATCH_BRANCH
git checkout $PATCH_BRANCH
git pull
export VER=`cat build/RELEASE`
echo "Current release $VER"
cd ..

# if [ $SKIP_SRC -eq 0 ] && [ ! -f $SRC_TAR ]
# then
# 	aria2c "https://commondatastorage.googleapis.com/chromium-browser-official/$SRC_TAR"
# else
# 	echo "Skipped downloading source tarball."
# 	echo
# fi

echo
echo sync chromium repo
echo 
mkdir -p ./chromium
pushd ./chromium > /dev/null

gclient root

mkdir -p ./src
cd ./src

git init
git remote add origin https://chromium.googlesource.com/chromium/src.git || true

git fetch --depth 2 https://chromium.googlesource.com/chromium/src.git +refs/tags/$VER:chromium_$VER
git checkout $VER
VERSION_SHA=$( git show-ref -s $VER | head -n1 )

echo >../.gclient "solutions = ["
echo >>../.gclient "  { \"name\"        : 'src',"
echo >>../.gclient "    \"url\"         : 'https://chromium.googlesource.com/chromium/src.git@$VERSION_SHA',"
echo >>../.gclient "    \"deps_file\"   : 'DEPS',"
echo >>../.gclient "    \"managed\"     : True,"
echo >>../.gclient "    \"custom_deps\" : {"
echo >>../.gclient "    },"
echo >>../.gclient "    \"custom_vars\": {},"
echo >>../.gclient "  },"
echo >>../.gclient "]"
echo >>../.gclient "target_os=['android']"

git submodule foreach git config -f ./.git/config submodule.$name.ignore all
git config --add remote.origin.fetch '+refs/tags/*:refs/tags/*'

echo
echo sync third_party repos
echo
gclient sync -D --no-history --nohooks

git config user.email "you@example.com"
git config user.name "Your Name"

# echo
# if [ $SKIP_EXTRACT -eq 0 ] && [ ! -d "$SRC_DIR" ]
# then
# 	echo Extracting Chromium $VER
# 	tar xf $SRC_TAR
# else
# 	echo "Skipped extracting the source tarball"
# fi
echo
popd > /dev/null