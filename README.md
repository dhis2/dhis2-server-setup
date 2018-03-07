# DHIS 2 server setup

Server administration scripts, tools and setup.

## Play

To initiate a new instance from the beginning:

* Add location for DHIS 2 instance in nginx dhis config

* Restart nginx

```
sudo service nginx restart
```

* Create Tomcat instance (provide instance version and port number)

```
./create-instance.sh 2.28 8028
```

* View Tomcat log for instance

```
./log-instance.sh 2.28
```

* Download and install DHIS 2 WAR file

```
./reinit-instance.sh 2.28
 ```
 
* Download, create and install sample PostgreSQL database

```
./reinit-db-instance.sh 2.28
 ```

* Restart Tomcat instance

```
./restart-db-instance.sh 2.28
 ```

* Start Tomcat instance

```
./start-db-instance-v2.sh 2.28
 ```

* Stop Tomcat instance

```
./stop-db-instance-v2.sh 2.28
 ```
 
 * Clear nginx cache
 
```
./clear-nginx-cache.sh
 ```
 ## CI
 
 * Fetch latest sample PostgreSQL database from S3
 
```
./sync-db-s3.sh
 ```
 
 * Copy WAR to S3
 
```
./sync-war-s3.sh 2.28
 ```
 
