#!/usr/bin/env bash
echo '_______________________НАЧИНАЮ ИМПОРТ ИЗ ФАЙЛОВ__________________'
bash ./$(dirname $0)/import.sh

echo '_______________________НАЧИНАЮ ОБНОВЛЕНИЕ СХЕМЫ__________________'
psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB -f ./$(dirname $0)/update_schema.sql

echo '_______________________НАЧИНАЮ СОЗДАНИЕ ИНДЕКСОВ_________________'
psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB -f ./$(dirname $0)/indexes.sql

echo '_______________________ _________ГОТОВО________ _________________'
