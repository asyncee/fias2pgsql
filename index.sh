echo '_______________________НАЧИНАЮ ИМПОРТ ИЗ ФАЙЛОВ__________________'
bash import.sh

echo '_______________________НАЧИНАЮ ОБНОВЛЕНИЕ СХЕМЫ__________________'
psql postgresql://$USER:$PASSWORD@$HOST:$PORT/$DB -f update_schema.sql

echo '_______________________НАЧИНАЮ СОЗДАНИЕ ИНДЕКСОВ_________________'
psql postgresql://$USER:$PASSWORD@$HOST:$PORT/$DB -f indexes.sql

echo '_______________________ _________ГОТОВО________ _________________'
