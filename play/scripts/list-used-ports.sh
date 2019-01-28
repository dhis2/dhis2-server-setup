#!/bin/bash

# Provides a quick list of which ports tomcat is running on for each instance on the server

egrep "Connector" /ebs1/instances/*/tomcat/conf/server.xml | grep "protocol=\"HTTP" | sed 's:.*\/instances\/\([^/]*\).*port="\([0-9]*\).*:\1\:\t\2:'
