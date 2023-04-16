#!/bin/bash

set -e
source vars.sh

cd $SRC_DIR
echo "Applying patches..."
for file in $(cat $BASE_DIR/bromite/build/bromite_patches_list.txt) ; do
# for file in $(ls -1 ../bromite/build/patches/*.patch) ; do
	echo " -> Apply $file"

	REPL="0,/^---/s//FILE:"$file"\n---/"
	cat $BASE_DIR/bromite/build/patches/$file | sed $REPL | git am
	# cat $file | sed $REPL | patch -Np1
	# patch -Np1 -i $file

	if [ $? -ne 0 ]
	then
        echo -e "Error on bromite/build/patches/${file}"
		cd ..
        exit 1
	fi

	echo " "
done
