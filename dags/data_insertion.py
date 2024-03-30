import pandas as pd
from airflow.providers.postgres.hooks.postgres import PostgresHook


def insert_data_from_files(file_paths, table_names, **kwargs):
    pg_hook = PostgresHook(postgres_conn_id='postgres_localhost')
    
    for file_key, file_path in file_paths.items():
        table_name = table_names.get(file_key)
        if not table_name:
            raise ValueError(f"No table name found for file '{file_key}'")

        df = pd.read_excel(file_path)
        # Insert data into the corresponding table
        pg_hook.insert_rows(table=table_name, rows=df.values.tolist())


