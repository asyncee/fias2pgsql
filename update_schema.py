# coding: utf-8
#!/usr/bin/env python

import json


update_column_sql = """
-- cast column {table}.{column} to {cast}
BEGIN;
    alter table {table} rename column {column} to {column}_x;
    alter table {table} add column {column} {cast};
    update {table} set {column} = {column}_x::{cast};
    alter table {table} drop column {column}_x;
COMMIT;
"""

replace_empty_sql = """
--- update empty values for {table}.{column}
UPDATE {table} SET {column} = NULL WHERE {column} = '';
"""


def update_column(table, column, cast):
    """Привести данные в столбце к нужному типу данных."""
    return update_column_sql.format(table=table, column=column, cast=cast)


def null(table, column):
    """Установить пустые значения в колонке в NULL."""
    return replace_empty_sql.format(table=table, column=column)


if __name__=='__main__':

    sql = []

    spec = json.load(open('schema.json', 'r'))
    tables_to_process = spec['process_tables']
    for table, task in spec['schema'].items():
        if table in tables_to_process:
            sql.append(
                "\n--============ {} ============--\n".format(table.upper()))
            for column in task.get('null', []):
                sql.append(null(table, column))
            for column, cast in sorted(task.get('convert', {}).items()):
                sql.append(update_column(table, column, cast))

    with open('update_schema.sql', 'w') as f:
        f.writelines(sql)
