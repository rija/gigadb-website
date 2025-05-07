# DATACITE API

## Check for missing DOIs on the DATACITE API

To run the check command on AWS deployment, from the bastion server:

```
$ docker run --rm -e YII_PATH=/var/www/vendor/yiisoft/yii -v /home/centos:/var/www/protected/runtime registry.gitlab.com/gigascience/forks/rija-gigadb-website/production_app:staging /var/www/protected/yiic checkdoiexistsindataciteapi
```

## update medatada to the DATACITE API

To run the update command on AWS deployment, from the bastion server:

```
docker run --rm -e YII_PATH=/var/www/vendor/yiisoft/yii -v /home/centos:/var/www/protected/runtime registry.gitlab.com/gigascience/forks/rija-gigadb-website/production_app:staging /var/www/protected/yiic updatedatasetdatacite
```

## Optional Parameters:

- Limit (--limit): Defines the batch size (default is 50). If you set a value greater that 450, it will automatically be capped at 450 to comply
with the rate limiter imposed by the Datacite API. 

- Offset (--offset): Specifies the starting point if you want to skip a number of records.
- DOI (--doi): Allows you to update a specific DOI.

## Logging:

you can redirect both standard and error output to a log file using:

```
> my_log.txt 2>&1
```
