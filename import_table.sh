#!/usr/bin/env bash

echo "++++++++++++++++++ HELLO, DB = $POSTGRES_DB"

TBL_TO_LOAD=$1

echo "++++++++++++++++++ LOADING TABLE = $TBL_TO_LOAD"

first_loop_flag=true

for FULLPATH in `find $PATH_TO_DBF_FILES/$TBL_TO_LOAD* -type f`
do
    FILE="${FULLPATH##*/}"
    TABLE="${FILE%.*}"

    pgdbf $FULLPATH | iconv -f cp866 -t utf-8 | psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB
    echo "++++++++++++++++++ TABLE $TABLE CREATED"

    if [[ "$first_loop_flag" = true ]]; then
      psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB -c "CREATE TABLE IF NOT EXISTS $TBL_TO_LOAD  AS SELECT * FROM $TABLE WHERE 0 = 1"
      echo "++++++++++++++++++ TABLE $TBL_TO_LOAD CREATED"
      first_loop_flag=false
    fi

    echo "++++++++++++++++++ INSERT $TABLE DATA INTO $TBL_TO_LOAD"
    psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB -c "INSERT INTO $TBL_TO_LOAD SELECT * FROM $TABLE;"

    if [[ "$TABLE" -ne "$TBL_TO_LOAD" ]]; then
        psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB -c "DROP TABLE $TABLE;"
    fi

done
