#!/usr/bin/env bash

# Make an environment file
if [[ ! -f .env ]];then
  cp ./env-default .env
fi

PATH=/usr/local/bin:$PATH
export PATH

# Download java source files
# docker-compose run --rm uploader curl -L -O https://github.com/gigascience/ExceltoGigaDB/archive/develop.zip
docker-compose run --rm uploader curl -L -O https://github.com/kencho51/ExceltoGigaDB/archive/refs/heads/remove-adding-non-exist-sample-attribute-feature.zip

# Unpack source files in place
docker-compose run --rm uploader bsdtar -k --strip-components=1 -xvf remove-adding-non-exist-sample-attribute-feature.zip


