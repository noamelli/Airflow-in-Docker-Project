# data_insertion.py

import pandas as pd
from airflow.providers.postgres.hooks.postgres import PostgresHook

def insert_data_to_postgres(file_path, table_name, **kwargs):
    pg_hook = PostgresHook(postgres_conn_id='postgres_localhost')
    df = pd.read_excel(file_path)

    if table_name == 'MRR_Fact_Orders':
        query = """
        INSERT INTO MRR_Fact_Orders (Order_ID, Order_Time, Customer_ID, Employee_ID, Shipper_ID, Freight)
        SELECT * FROM {table}
        WHERE Order_ID NOT IN (
            SELECT DISTINCT Order_ID 
            FROM DWH_Fact_Product_In_Order
        );
        """.format(table=table_name)
        pg_hook.run(query)
    elif table_name == 'MRR_Fact_Details':
        query = """
        INSERT INTO MRR_Fact_Details (Order_ID, Product_ID, Quantity)
        SELECT * FROM {table}
        WHERE Order_ID NOT IN (
            SELECT DISTINCT Order_ID 
            FROM DWH_Fact_Product_In_Order
        );
        """.format(table=table_name)
        pg_hook.run(query)
    else:
        pg_hook.insert_rows(table=table_name, rows=df.values.tolist())

def insert_data_from_files(file_paths, table_names, **kwargs):
    pg_hook = PostgresHook(postgres_conn_id='postgres_localhost')
    
    for file_key, file_path in file_paths.items():
        table_name = table_names.get(file_key)
        if not table_name:
            raise ValueError(f"No table name found for file '{file_key}'")

        df = pd.read_excel(file_path)
        # Insert data into the corresponding table
        pg_hook.insert_rows(table=table_name, rows=df.values.tolist())
