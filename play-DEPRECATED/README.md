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
./create-instance.sh <name/version> 8028 <dhis2-release-version>

# if <dhis2-release-version> is provided then it is used to define the build,
# and the first parameter is simply the name of the instance.
# If <dhis2-release-version> is not provided, the first parameter represents
# both the name of the instance and the build version used.

e.g.
./create-instance.sh 2.28 8028
or
./create-instance.sh my2.31patch0 8031 2.31/2.31.0

```

> NOTE:
> When `<dhis2-release-version>` is used it creates a file called
> `<instance-directory>/DHIS2_VERSION` containing the build identifier.
> It also created a file called `<instance-directory>/DHIS2_DB_VERSION` with
> the same content, which is used to identify the demo DB to be used.
>
> Both of these files should be manually edited if you want the instance to
> be updated from different paths.


* View Tomcat log for instance

```
./log-instance.sh 2.28
```

* List the ports used by Tomcat for all instance

```
./list-used-ports.sh
```

* Download and install DHIS 2 WAR file

```
./reinit-instance.sh 2.28
 ```

* Download, create and install sample PostgreSQL database

```
./reinit-db-instance.sh 2.28
```

* Download and install *BOTH* the sample PostgreSQL database and DHIS 2 WAR file in one go

```
./init-full-instance.sh 2.28
```

* Restart Tomcat instance

```
./restart-instance.sh 2.28
 ```

* Start Tomcat instance

```
./start-instance.sh 2.28
 ```

* Stop Tomcat instance

```
./stop-instance.sh 2.28
 ```

 * Clear nginx cache

```
./clear-nginx-cache.sh
 ```
