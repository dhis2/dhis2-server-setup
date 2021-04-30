#!/bin/bash

# INIT
. env.sh

# GLOBALS
# ---
# TMP_DIR
# BASE_DIR

# Provides a quick list of which ports tomcat is running on for each instance on the server

egrep "Connector" ${BASE_DIR}/*/tomcat/conf/server.xml | grep "protocol=\"HTTP" | sed "s:.*\/\([0-9.]*\)\/tomcat\/.*port=\"\([0-9]*\).*:\1\:\t\2:"
