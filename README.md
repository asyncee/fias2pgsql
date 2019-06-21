# Импорт данных из ФИАС в Postgresql


### История изменений

1. Скрипты импорта обновлены 9 января 2019, спасибо [xlazex](https://github.com/xlazex)
2. Скрипты импорта обновлены 20 июня 2019, спасибо [hedgehogues](https://github.com/hedgehogues)

### Краткое описание

Все манипуляции проводились на [postgresql](https://www.postgresql.org/) версии 11.x.x, однако всё должно
работать и на младших версиях, вплоть до 9.x.x.

Краткая суть импорта данных заключается в следующем:

1. Импорт данных из *\*.dbf* файлов в postgresql используя утилиту *pgdbf v0.6.2*.
2. Приведение полученной схемы данных в надлежащее состояние, в т.ч. изменение типа данных колонок.
3. Удаление исторических данных (неактуальных адресных объектов) - опционально, см. пункт 6 секции "Использование"
4. Создание индексов


В скрипте импортируются только следующие таблицы:

- ``addrobj`` - Классификатор адресообразующих элементов (край > область >
  город > район > улица)
- ``socrbase`` - Типы адресных объектов (условные сокращения и уровни
  подчинения)

Если необходимо импортировать и другие данные, то это можно сделать с помощью
правки скрипта ``import.sh``.


### Использование

Используемые переменные окружения:

`$POSTGRES_DB` - имя БД, в которую будет осуществлён импорт

`$POSTGRES_USER` - имя юзера, от имени которого будет осуществлён импорт

`$POSTGRES_PASSWORD` - пароль для `$POSTGRES_USER` к БД

`$POSTGRES_HOST` - хост БД

`$POSTGRES_PORT` - порт БД

`$PATH_TO_DBF_FILES` - путь к файлам *\*.dbf*

По умолчанию переменные окружения не задаются, их необходимо указать самостоятельно.

Алгоритм действий:

1. Развернуть БД postgres. Это можно сделать с помощью 
[docker-compose.yml](https://github.com/Hedgehogues/fias2pgsql/blob/master/docker-compose.yml), который присутствует в 
репозитории или непосредственно поднять БД руками. Для того, чтобы воспользоваться *docker-compose*, потребуется 
[docker](https://www.docker.com/) и [docker-compose](https://docs.docker.com/compose/install/). После установки следует запустить контейнер с postgres-11:

```
    docker-compose up
```

*Замечание*: настоятельно рекомендуется отказаться от использования докера на боевом сервере для базы. Если 
всё-таки принято решение использовать докер, ознакомьтесь с [этим](https://ru.stackoverflow.com/questions/712931/%D0%97%D0%B0%D0%BF%D1%83%D1%81%D0%BA-postgresql-%D0%B2-docker/779716#779716) и
[этим](https://toster.ru/q/534239) материалами. В данном случае докер — возможность быстро опробовать наши утилиты.

2. Вам также потребуется клиент к postgres-11:

```
    sudo apt-get install postgresql-client
```

В результате, будет доступна утилита `psql`. Присоединиться к БД можно так:

    psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB
 
3. Скачать [архив](https://fias.nalog.ru/Updates.aspx) с DBF-файлами сайта ФИАС. Он весит примерно 6 ГБ на момент 
обновления
4. Распаковать его в любую директорию
5. ВМЕСТО ПУНКТОВ 4,6,7 (если не требуется пункт 5) можно выполнить (либо использовать кастомные настройки):

```
    POSTGRES_DB=test_db POSTGRES_USER=test POSTGRES_PASSWORD=test POSTGRES_HOST=localhost POSTGRES_PORT=5432 PATH_TO_DBF_FILES=/path/to/your/files/ bash ./index.sh
```

6. Создать бд и провести начальный импорт данных:

```
    POSTGRES_DB=test_db POSTGRES_USER=test POSTGRES_PASSWORD=test POSTGRES_HOST=localhost POSTGRES_PORT=5432 PATH_TO_DBF_FILES=/path/to/your/files/ bash ./import.sh
```

7. Если нужно, изменить настройки обновления схемы данных в schema.json и
   выполнить скрипт ``update_schema.py``. Это создаст обновлённый файл
   ``update_schema.sql``.

8. Обновить схему данных:

```
    psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$HOST:$POSTGRES_PORT/$POSTGRES_DB -f update_schema.sql
```

9. Удалить неактуальные данные и создать индексы::

```
    psql postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB -f indexes.sql
```

10. Проверить скорость выполнения следующих запросов::

    -- вывести полный адрес
    WITH RECURSIVE child_to_parents AS (
    SELECT addrobj.* FROM addrobj
        WHERE aoid = '51f21baa-c804-4737-9d5f-9da7a3bb1598'
    UNION ALL
    SELECT addrobj.* FROM addrobj, child_to_parents
        WHERE addrobj.aoguid = child_to_parents.parentguid
            AND addrobj.currstatus = 0
    )
    SELECT * FROM child_to_parents ORDER BY aolevel;

    -- поиск по части адреса
    SELECT * FROM addrobj WHERE formalname ILIKE '%Ульян%';
