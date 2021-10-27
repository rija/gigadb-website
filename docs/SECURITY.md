# Ports

## Used ports

| Port number | Protocol | open on servers |
| --- | --- | --- |
| 80 | HTTP | web | 
| 443 | HTTPS | web |
| 2376 | Docker | web |
| 9000 | PHP-FPM | application |
| 5432 | PostgresQL | AWS RDS |
| 22 | SSH | bastion |
| 21 | FTP | CNGB FTP |

## Scanning for open ports

```
$ docker-compose run --rm test bash -c 'nc -z -v <host> 1-65535' | grep succeeded
```
