#!/bin/bash

reset_instance () {
    BASE_URL="https://play.dhis2.org/""$1""/api/"
    CREDS="system:System123"
   
    curl -X POST -H "Content-Type: text/plain" -d "iso8601" $BASE_URL"/systemSettings/keyCalendar" -u $CREDS
    
    curl -d @admin-metadata.json $BASE_URL"/metadata" -X POST -H "Content-Type: application/json" -u $CREDS
    


    HTTP_STATUS=`curl -I $BASE_URL"/me" -u admin:district 2>/dev/null | head -n 1 | awk -F" " '{print $2}'`
    
    if [ $HTTP_STATUS -ne 200 ]; then
        sudo -u postgres psql -c "UPDATE users set
        password='\$2a\$10\$ZnK2hycBfMOL9WNtzpp18.jKuWXRW4ubdWew6ckQNw7NBESjtXdFe'
        where username='admin';" $1
        echo "Hammertime!"
    fi

    curl -X POST $BASE_URL"maintenance/cacheClear" -u $CREDS
}
declare -a instances=("demo" "dev" "2.31" "2.31-rc1" "2.30" "2.29" "2.28" "2.27" "2.26")

for i in "${instances[@]}"
do
   reset_instance $i
done
