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
./create-instance.sh 2.25 8025
```

* Download and install DHIS 2 WAR file

```
./reinit-instance-v2.sh 2.25
 ```
 
* Download, create and install sample PostgreSQL database

```
./reinit-db-instance-v2.sh 2.25
 ```

