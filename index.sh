#!/usr/bin/env bash
echo '_______________________НАЧИНАЮ ИМПОРТ ИЗ ФАЙЛОВ__________________'
echo $POSTGRES_DB
echo $POSTGRES_USER
bash import.sh

echo '_______________________НАЧИНАЮ ОБНОВЛЕНИЕ СХЕМЫ__________________'
psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB -f update_schema.sql

echo '_______________________НАЧИНАЮ СОЗДАНИЕ ИНДЕКСОВ_________________'
psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB -f indexes.sql

echo '_______________________ _________ГОТОВО________ _________________'
