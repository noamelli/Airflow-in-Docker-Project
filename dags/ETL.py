from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
import pandas as pd
from airflow.operators.python_operator import PythonOperator
from data_insertion import insert_data_from_files

 
default_args={
    'owner':'coder2j',
    'retries':5,
    'retry_delay':timedelta(minutes=5)
}

dag = DAG(
    dag_id='ETL_Flow',
    start_date=datetime(2024,3,21),
    schedule_interval='11 21 * * *',
    default_args=default_args,
    description='ETL Flow'
)

file_paths = {
    'customers': '/opt/airflow/dags/operationalData/customers.xlsx',
    'employees': '/opt/airflow/dags/operationalData/employees.xlsx',
    'products': '/opt/airflow/dags/operationalData/products.xlsx',
    'orders': '/opt/airflow/dags/operationalData/orders.xlsx',
    'details': '/opt/airflow/dags/operationalData/details.xlsx'
}

table_names = {
    'customers': 'MRR_Dim_Customers',
    'employees': 'MRR_Dim_Employees',
    'products': 'MRR_Dim_Products',
    'orders': 'MRR_Fact_Orders',
    'details': 'MRR_Fact_Details'
}


create_tables = PostgresOperator(
     task_id='create_tables',
     postgres_conn_id='postgres_localhost',
     sql='sql/create_tables.sql',
     dag=dag
 ) 
    
truncate_mrr_stg = PostgresOperator(
        task_id='truncate_mrr_stg',
        postgres_conn_id='postgres_localhost',
        sql='sql/truncate_mrr_stg.sql',
        dag=dag
)

dwh_backup = PostgresOperator(
        task_id='dwh_backup',
        postgres_conn_id='postgres_localhost',
        sql='sql/dwh_backup.sql',
        dag=dag
)

insert_data_task = PythonOperator(
    task_id='insert_data_from_files',
    python_callable=insert_data_from_files,
    op_kwargs={'file_paths': file_paths, 'table_names': table_names},
    dag=dag
)

dim_mrr2stg = PostgresOperator(
        task_id='dim_mrr2stg',
        postgres_conn_id='postgres_localhost',
        sql='sql/dim_mrr2stg.sql',
        dag=dag
)

dim_stg2dwh = PostgresOperator(
        task_id='dim_stg2dwh',
        postgres_conn_id='postgres_localhost',
        sql='sql/dim_stg2dwh.sql',
        dag=dag
)

fact_mrr2stg = PostgresOperator(
        task_id='fact_mrr2stg',
        postgres_conn_id='postgres_localhost',
        sql='sql/fact_mrr2stg.sql',
        dag=dag
)    

referential_integrity = PostgresOperator(
        task_id='referential_integrity',
        postgres_conn_id='postgres_localhost',
        sql='sql/referential_integrity.sql',
        dag=dag
)  

fact_stg2dwh = PostgresOperator(
        task_id='fact_stg2dwh',
        postgres_conn_id='postgres_localhost',
        sql='sql/fact_stg2dwh.sql',
        dag=dag
)  

snapshot = PostgresOperator(
        task_id='snapshot',
        postgres_conn_id='postgres_localhost',
        sql='sql/snapshot.sql',
        dag=dag
)      

#DAG FLOW
create_tables>> truncate_mrr_stg >> dwh_backup  >> insert_data_task >> dim_mrr2stg >>dim_stg2dwh >>fact_mrr2stg>>referential_integrity >> fact_stg2dwh >> snapshot
