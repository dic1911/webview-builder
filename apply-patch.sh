#!/bin/bash

set -e
source vars.sh

cd $SRC_DIR
echo "Applying patches..."
for file in $(cat $BASE_DIR/cromite/build/cromite_patches_list.txt) ; do
# for file in $(ls -1 ../cromite/build/patches/*.patch) ; do
	echo " -> Apply $file"

	REPL="0,/^---/s//FILE:"$file"\n---/"
	ERR=0
	cat $BASE_DIR/cromite/build/patches/$file | sed $REPL | git am || ERR=$?
	# cat $file | sed $REPL | patch -Np1
	# patch -Np1 -i $file

	if [ $ERR -ne 0 ]
	then
        echo -e "Error on cromite/build/patches/${file}, skipping"
		git am --abort
		git reset --hard
		# cd ..
        # exit 1
	fi

	echo " "
done
