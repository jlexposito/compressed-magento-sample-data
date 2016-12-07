#!/bin/bash

#
# This script agressivly compresses the magento sample data images and mp3 files
# Use at your own risk!
#
# It is a quick hack, intended only to run on OSX with the following dependencies:
# - ImageMagick (that is, the convert command)
# - lame
# - curl (only for downloading the sample data)
# - 7za
#
# (c) 2014 Vinai Kopp <vinai@netzarbeiter.com>
# 

TARGET_IMAGE_QUALITY_PERCENTAGE=50
EXCLUDE_FILES='\._*'


if [ -z "$1" ]; then
    echo "No sample data specified."

elif echo "$1" | grep -q '^https\?:'; then
    download="$1"
fi

if [ -n "$download" ]; then
    echo "Downloading $download"
    curl -O "$download"
    SOURCE_ARCHIVE="$(realpath "$(basename "$download")")"

elif [ -n "$1" ]; then
    SOURCE_ARCHIVE="$(realpath "$1")"
fi

[ ! -e "$SOURCE_ARCHIVE" ] && {
    echo -e "Usage:\n$0 magento-sample-data-1.x.x.x.tar.bz2"
    exit 2
}
echo "Using sample data $SOURCE_ARCHIVE"


SAMPLE_DATA_DIR="$(tar -jxvf  "magento-sample-data-1.9.2.4-2016-10-11-06-57-39.tar.bz2" | head -1 | xargs basename)"
echo "SAMPLE DATA DIRECTORY $SAMPLE_DATA_DIR"

echo "Extracting sample data"
tar -jxf  "$SOURCE_ARCHIVE"

echo "Removing resized images cache files"
rm -rf "$SAMPLE_DATA_DIR"/media/catalog/product/cache/*

echo "Compressing images..."
find $SAMPLE_DATA_DIR -name "*.jpg" -exec convert -quality 50% {} {} \;
find $SAMPLE_DATA_DIR -name "*.png" -exec convert -quality 50% {} {} \;
find $SAMPLE_DATA_DIR -name "*.gif" -exec convert -quality 50% {} {} \;

#echo "Compressing mp3 files..."
#find "$SAMPLE_DATA_DIR" -type f -iname '*.mp3' -exec lame --silent -b $TARGET_MP3_BITRATE "{}" "{}.out" \; -exec mv "{}.out" "{}" \;

echo "Deleting mp3 files..."
find . -name "*.mp3" -exec rm {} \;

echo "Building new sample data archive compressed-$SAMPLE_DATA_DIR.tar.bz2..."
tar -cjf "compressed-$SAMPLE_DATA_DIR.tar.bz2" $SAMPLE_DATA_DIR
rm -rf $SAMPLE_DATA_DIR

NEW_SIZE=$(du -sh "compressed-$SAMPLE_DATA_DIR.tar.bz2" | awk '{ print $1 }')
ORIG_SIZE=$(du -sh "$SOURCE_ARCHIVE" | awk '{ print $1 }')
echo "New size : 		$NEW_SIZE"
echo "Original size:    $ORIG_SIZE"