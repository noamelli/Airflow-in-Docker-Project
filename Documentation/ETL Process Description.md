
# ETL Process

1. Create all of the tables if they do not exist. 
2. Truncate MRR and STG tables, so we can load them with new records.
3. Backup DWH tables - truncate backup tables and then load them with the records in DWH tables. 
4. Extract data from Excel and load to MRR tables. Unlike the other tasks, this one uses a python operator and executes functions that use pandas in order to read from Excel. 
    1. The initial loading to MRR tables is full. 
    2. There are two MRR fact tables: orders and details. The details table shows the quantity sold for each product in each order. 
    3. The data type of all columns in MRR tables is varchar, in case the data shown in the file doesn't match the desired format. This is how we avoid a failure of the program.
    4. All of the excel files contains a column called "IsValid".
        1. When someone add a record to this file he have to set the value "valid" in this column.
        2. In case of adding a record with a primary key that is already exists in the file, one should upadte the old record with "not valid" value. 
        3. This column enable us to avoid duplicate key value issues, in this way we will insert valid records. 
5. Loading the data from MRR Dim tables to STG Dim tables. 
    1. The Loading is full. We will load all of the valid records with "valid" value in "IsValid" column. 
    2. We will cast the column data type to the desired one. 
    3. We will check whether the format  of the value inserted is correct. If it's wrong or the value is null - we will change the format or insert the agreeable one
    according to this convention : 
      1. If the column data type is varchar and the value is null while it cannot be null -> the default value will be "missing". 
      2. If the column data type is numeric (decimal or integer) and it represent amount/money -> the default value will be null, in order to avoid data distortion.
      3. If the column data type is numeric (decimal or integer) and it doesn't represent amount/money -> the default value will be 0.
      4. If the column data type is date the value doesn't match the one of the desired formats -> the default value will be '1900-01-01'.
    4. Generating dates and time tables.
6. Loading the data from STG Dim tables to DWH Dim tables. 
    1. Truncate DWH Dates and time tables, so we can load them with the relevant records (full load). 
    2. We will treat customers, employees and products as slowly changing dimension type 2 and save versions when one of the following columns value change:
    - Customers - city, country. 
    - Products - unit_cost, unit_price, supplier. 
    - Employees - reports_to, title, month_salary, office. 
    3. The loading consists of three stages:
        1. Inserting all of the new records based on the primary key of the STG table. When a record is being added, it automatically gets DW value - a column identifier that gets the value: identity (1,1). It also gets a valid from value (default - current date) and the valid until will be null.  
        2. Updating the valid until in old records that at least one of the relevant columns has changed.
        3. Inserting new records with the new value. The valid from value is the current date and the valid until is null. 
7. Loading data from MRR fact tables to STG fact tables. 
    1. The loading is full.
    2. We will cast the column data type to the desired one. 
    3. We will check whether the format  of the value inserted is correct. If it's wrong or the value is null - we will change the format or insert the agreeable one
    according to this convention : 
       1. If the column data type is numeric (decimal or integer) and it represent amount/money -> the default value will be null, in order to avoid data distortion.
       2. If the column data type is numeric (decimal or integer) and it doesn't represent amount/money -> the default value will be 0.
       3. If the column data type is datetime the value doesn't match the one of the desired formats -> the default value will be '1900-01-01 00:00:00'.
8. Referential Integrity -  if the fact tables contain dimensions that are not shown in DWH Dim tables we will mark their key and set it to 0. 
9. Loading data from STG fact tables to DWH fact table - Product_In_Order.
    1. The loading is incremental - we will load orders that their order id isn't shown in the DWH table.
    2. We will combine STG_Fact_Orders with STG_Fact_Details using inner join. 
    3. We will also combine DWH Dim tables and select only the most recent records (where valid until = null).   
    4. we will create calculated fields : total_price, total_cost.  
10. Updating DWH_Snapshot_Customers_Transactions. This table shows the transaction numbers (new customers, abandoned, etc..) in each year, quarter and month. 

## Snapshot table logic 
1. Updating relevant_periods table - a view containning all of the months and years that have been ended and havn't been loaded to Snapshot_Customers_Transactions_Arch yet (an explantion of the table is mentioned next). 

This view contains these columns: 
- Start date of month.
- last date of month.

2. Loading status_calculation - a view that shows for each customer the start date of the relevant month and his status.
    1. The first date of the month will be the Start date from the relevant_periods table. It means that status_calculation will only contain a reference to the months shown in relevant_periods and will be updated regularly.
    2. The use of the month start date field stems from the idea that the view is monthly and not daily, but on the other hand we want to store the month and the year as well.
    3. For each customer we will check his status in the each month shown in relevant_periods, according to the calculation mentioned next. This is the reason for using cross join between relevant_periods and DWH_Dim_Customers tables.
    4. The status will be shown for each dwh_customer record, in which the valid until is not null. It stems from the idea that in the final table (DWH_Snapshot_Customers_Transactions) we will show the country for each customer, so we need to use the relevant record. 
4. Loading Snapshot_Customers_Transactions_Arch - a table containing historical data. It shows for each customer his status at each start date of the month. 
5. Loading DWH_Snapshot_Customers_Transactions.
    1. Incremental loading - we will load only breakdowns combinations that are not shown in the table (year, month, quarter, county). 
    2. We will use Inner join with DWH_Dim_Customers, in order to show the country dimension. 


## Status calculation
1. New - a customer that the first time he ordered was in the month we check. 
2. Abandoned - a customer who hasn't bought for the last 3 months (including the month we refer to).  
3. Reactivated - a customer who was marked as an abandoner two months ago and in the month we check - he made a purchase.  
4. regular - a customer who isn't new or did not abandon/Reactivate. 


## Business assumptions:
1. Every time we update the snapshot table, we refer to the months that have ended. This is because we don't want to measure customer behavior in a month that hasn't ended yet. For example, it is possible that a customer did not have time to purchase this month and will purchase later, so we would not want to categorize him as “Abandoned “.
2. relevant_periods may contain months that for some reason were not loaded into the archive table. In this way we guarantee that every combination of year and month will necessarily be loaded into the tables and possibly only once.



