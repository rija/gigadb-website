#!/bin/bash

# Exit script on error
set -e

if [[ -z "$1" ]]; then
    echo "Error: DOI is required!"
    echo "Usage: calculate_checksum_sizes.sh <DOI>"
    exit 1
fi

doi="$1"

MD5_FILE="$doi.md5"
FILESIZE_FILE="$doi.filesizes"
S3_BUCKET="s3://gigadb-datasets-metadata"

echo $MD5_FILE
echo $FILESIZE_FILE

# Create doi.md5 file containing md5 checksum values for files
find .  -type f ! -name "$MD5_FILE" ! -name "$FILESIZE_FILE" -exec md5sum {} \; > "$MD5_FILE"
echo "Created $MD5_FILE"

# Create doi.filesizes file containing file size information
for i in $(find .  -type f ! -name "$MD5_FILE" ! -name "$FILESIZE_FILE");
do
  echo -e "$(wc -c < $i)\t$i" >> "$FILESIZE_FILE"
done
echo "Created $FILESIZE_FILE"

## In case we are on GigaDB file server
#if [[ $(uname -n) =~ cngb-gigadb-ftp ]];then
#  export AWS_CONFIG_FILE=/etc/aws/config
#  export AWS_SHARED_CREDENTIALS_FILE=/etc/aws/credentials
#fi
#
## Copy files into S3 bucket
#aws s3 cp "$FILESIZE_FILE" "$S3_BUCKET"
#aws s3 cp "$MD5_FILE" "$S3_BUCKET"