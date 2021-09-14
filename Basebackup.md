## PostgreSQL Basebackup 

### Perform the Postgres Basebackup
####  Steps

- Stop the database 
```
systemctl stop postgresql-12.service
```
#### Use the Basebackup 

- create the backup 
```
$ pg_basebackup -h localhost -D /usr/local/pgsql/data

```
#### or we can create the archive 
```
$ pg_basebackup -D backup -Ft -z -P

```
#### Single-Table Local database 
```
$ pg_basebackup -D - -Ft -X fetch | bzip2 > backup.tar.bz2
```
--------------------------------------------------------------
### How to Restore the Basebackup
#### Delete the $PGDATA /12/data 
```
rm -rf ./data
```
#### Restore /data
```
cp -r ./backupfile/ ./12/data/
```
#### After Restoring the data Permistions to be needed
-
```
chmod 0750 -R /var/lib/pgsql/12/data

```
- Change the Ownership 
```
chown postgres:postgres  -R /var/log/pgbackrest
```
--------------------------------------------------------------
#### Restart the Database PostgreSQL 

```
systemctl restart postgresql-12.service
```
