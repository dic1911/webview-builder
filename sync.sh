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
# git pull
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
echo >>../.gclient "    \"managed\"     : False,"
echo >>../.gclient "    \"custom_deps\" : {"
echo >>../.gclient "        \"src/third_party/apache-windows-arm64\": None,"
echo >>../.gclient "        \"src/third_party/updater/chrome_win_x86\": None,"
echo >>../.gclient "        \"src/third_party/updater/chrome_win_x86_64\": None,"
echo >>../.gclient "        \"src/third_party/updater/chromium_win_x86\": None,"
echo >>../.gclient "        \"src/third_party/updater/chromium_win_x86_64\": None,"
echo >>../.gclient "        \"src/third_party/gperf\": None,"
echo >>../.gclient "        \"src/third_party/lighttpd\": None,"
echo >>../.gclient "        \"src/third_party/lzma_sdk/bin/host_platform\": None,"
echo >>../.gclient "        \"src/third_party/lzma_sdk/bin/win64\": None,"
echo >>../.gclient "        \"src/third_party/perl\": None,"
echo >>../.gclient "        \"src/tools/skia_goldctl/win\": None,"
echo >>../.gclient "        \"src/third_party/screen-ai/windows_amd64\": None,"
echo >>../.gclient "        \"src/third_party/screen-ai/windows_386\": None,"
echo >>../.gclient "        \"src/third_party/cronet_android_mainline_clang/linux-amd64\": None,"
echo >>../.gclient "        \"src/testing/libfuzzer/fuzzers/wasm_corpus\": None,"
echo >>../.gclient "    },"
echo >>../.gclient "    \"custom_vars\": {"
echo >>../.gclient "       \"checkout_android_prebuilts_build_tools\": True,"
echo >>../.gclient "       \"checkout_telemetry_dependencies\": False,"
echo >>../.gclient "       \"checkout_pgo_profiles\": 'True',"
echo >>../.gclient "       \"codesearch\": 'Debug',"
echo >>../.gclient "    },"
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

# from cromite script
gclient runhooks
tools/clang/scripts/update.py
tools/clang/scripts/update.py --package=objdump
rm -rf third_party/angle/third_party/VK-GL-CTS/

popd > /dev/null
