#!/bin/bash

echo "Clearing nginx cache"
sudo rm -rf /var/cache/nginx/

echo "Restarting nginx"
sudo service nginx restart
