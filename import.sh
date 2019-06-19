#!/bin/bash

echo "++++++++++++++++++ HELLO, DB = $DB"

echo '++++++++++++++++++ SOCRBASE TABLE CREATED'
echo
pgdbf $PATH_TO_FILES/SOCRBASE.DBF | iconv -f cp866 -t utf-8 | psql postgresql://$USER:$PASSWORD@$HOST:$PORT/$DB

echo '++++++++++++++++++ CHECKING ADDROBJ FILES'
if [ -f $PATH_TO_FILES/ADDROB01.DBF ]; then
   mv .$PATH_TO_FILES/ADDROB01.DBF $PATH_TO_FILES/ADDROBJ.DBF
   echo '++++++++++++++++++ ADDROBJ INITIAL FILE MOVED'
fi
pgdbf $PATH_TO_FILES/ADDROBJ.DBF | iconv -f cp866 -t utf-8 | psql postgresql://$USER:$PASSWORD@$HOST:$PORT/$DB
echo '++++++++++++++++++ INITIAL ADDROBJ TABLE CREATED'


for FULLPATH in `find $PATH_TO_FILES/ADDROB* -type f`
do
    FILE="${FULLPATH##*/}"
    TABLE="${FILE%.*}"

    if [ $TABLE = 'ADDROBJ' ]; then
      echo 'SKIPPING ADDROBJ'
    else
      pgdbf $FULLPATH | iconv -f cp866 -t utf-8 | psql postgresql://$USER:$PASSWORD@$HOST:$PORT/$DB
      echo "++++++++++++++++++ TABLE $TABLE CREATED"

      echo "++++++++++++++++++ INSERT $TABLE DATA INTO ADDROBJ"
      psql postgresql://$USER:$PASSWORD@$HOST:$PORT/$DB -c "INSERT INTO addrobj SELECT * FROM $TABLE; DROP TABLE $TABLE;"
    fi

done
