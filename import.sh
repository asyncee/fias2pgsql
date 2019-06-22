#!/usr/bin/env bash

echo "++++++++++++++++++ HELLO, DB = $POSTGRES_DB"
PATH_=$PATH_TO_DBF_FILES
echo "++++++++++++++++++ PATH_TO_FILES = $PATH_"

echo '++++++++++++++++++ SOCRBASE TABLE CREATED'
echo
pgdbf $PATH_/SOCRBASE.DBF | iconv -f cp866 -t utf-8 | psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB

echo '++++++++++++++++++ CHECKING ADDROBJ FILES'
if [ -f $PATH_/ADDROB01.DBF ]; then
   mv .$PATH_/ADDROB01.DBF $PATH_/ADDROBJ.DBF
   echo '++++++++++++++++++ ADDROBJ INITIAL FILE MOVED'
fi
pgdbf $PATH_/ADDROBJ.DBF | iconv -f cp866 -t utf-8 | psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB
echo '++++++++++++++++++ INITIAL ADDROBJ TABLE CREATED'


for FULLPATH in `find $PATH_/ADDROB* -type f`
do
    FILE="${FULLPATH##*/}"
    TABLE="${FILE%.*}"

    if [ $TABLE = 'ADDROBJ' ]; then
      echo 'SKIPPING ADDROBJ'
    else
      pgdbf $FULLPATH | iconv -f cp866 -t utf-8 | psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB
      echo "++++++++++++++++++ TABLE $TABLE CREATED"

      echo "++++++++++++++++++ INSERT $TABLE DATA INTO ADDROBJ"
      psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB -c "INSERT INTO addrobj SELECT * FROM $TABLE; DROP TABLE $TABLE;"
    fi

done
