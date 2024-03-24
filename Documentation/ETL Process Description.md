
# ETL Process

1. Create all of the tables if they do not exist. 
2. Truncate MRR and STG tables, so we can load them with new records.
3. Backup DWH tables - truncate backup tables and then load them with the records in DWH tables. 
4. Extract data from Excel and load to MRR tables. Unlike the other tasks, this one uses a python operator and executes functions that use pandas in order to read from Excel. 
    1. Dim tables - the initial loading to MRR dim tables is full. 
    2. Fact tables - the initial loading to MRR fact tables is incremental. We will load new orders that are not shown in the DWH tables. 
    There are two MRR fact tables: orders and details. The details table shows the quantity sold for each product in each order. 
    - The reason for this is the idea that an order that happened in the past will not change, so the record will not be updated either.
    - Therefore, in the following steps, the loading to STG and DWH fact tables will be full.
    - We will locate orders that are shown in the DWH tables based on the order ID key. 
    3. The data type of all columns in MRR tables is varchar, in case the data shown in the file doesn't match the desired format. This is how we avoid failure of the program.
5. Loading data from MRR Dim tables to STG Dim tables. 
    1. The Loading is full.
    2. We will cast the column data type to the desired one. 
    3. We will check whether the format  of the value inserted is correct. If it's wrong or the value is null - we will change the format or insert the agreeable one (0, null, etc..). 
    4. Generating dates and time tables.
6. Loading data from STG Dim tables to DWH Dim tables. 
    1. Truncate DWH Dates and time tables, so we can load them with the relevant records (full load). 
    2. We will treat customers, employees and products as slowly changing dimension type 2 and save versions when one of the next columns value change:
    - Customers - city, country. 
    - Products - unit_cost, unit_price, supplier. 
    - Employees - reports_to, title, month_salary, office. 
    3. The loading consists of three stages:
        1. Inserting all of the new records based on the primary key of the STG table. When a record is being added, it automatically gets DW value - a column identifier that gets the value: identity (1,1). It also gets a valid from value (default - current date) and the valid until will be null.  
        2. Updating the valid until in old records that at least one of the relevant columns has changed.
        3. Inserting new records with the new value. The valid from value is the current date and the valid until is null. 
7. Loading data from MRR fact tables to STG fact tables. 
    1. The loading is full because we already loaded incremental records to MRR.
    2. We will cast the column data type to the desired one. 
    3. We will check whether the format of the value inserted is correct. If it's wrong or the value is null - we will change the format or insert the agreeable one (0, null, etc..). 
8. Referential Integrity -  if the fact tables contain dimensions that are not shown in DWH Dim tables we will mark their key and set it to 0. 
9. Loading data from STG fact tables to DWH fact table -Product_In_Order.
    1. The loading is full.
    2. We will combine STG_Fact_Orders with STG_Fact_Details using inner join. We will also combine DWH Dim tables and select only the most recent records (where valid until = null).   
    3. we will create calculated fields : total_price, total_cost.  
10. Updating DWH_Snapshot_Customers_Transactions. This table shows the transaction numbers (new customers, abandoned, etc..) in each year, quarter and month. 

## Snapshot table logic 
1. Updating current_dates table - a one record view showing:
- Start date of previous month.
- last date of previous month.
- Previous month.
- Year of previous month.
- Quarter of previous month.
2. Loading Snapshot_Customers_Transactions_month - a view that shows for each customer the start date of the previous month and his status.
    1. The first date of the month will be the Start date from the current_dates table, which means the table will only contain a reference to the previous month and will be updated regularly.
    2. The use of the month start date field stems from the idea that the view is monthly and not daily, but on the other hand we want to store the month and the year.
    3. For each customer we will check his status in the previous month according to the calculation mentioned next. 
3. Next we will check whether the Snapshot_Customers_Transactions_Arch table contains the start of the previous month. If so, it means we have already loaded the previous month statuses, so we will stop at this point. Otherwise, we will continue to the next step.
4. Loading Snapshot_Customers_Transactions_Arch - a table containing historical data. It shows for each customer his status at each start date of the month. 
5. Loading DWH_Snapshot_Customers_Transactions.
    1. Incremental loading - we will load only breakdowns combinations that are not shown in the table (year, month, quarter, county, city). 
    2. We will use Inner join with DWH_Dim_Customers, in order to show the countries and the cities. 


## Status calculation
1. New - a customer that the year and month of the minimum valid from shown in DWH_Dim_Customers match the previous month. 
The reason for selecting the minimum is that a customer might change his address and then the new record will get an older valid until. 
2. Abandoned - a customer who hasn't bought for the last 3 months (including the month we refer to).  
3. Reactivated - a customer who was marked as an abandoner two months ago and in the previous month made a purchase.  
4. regular - a customer who isn't new or did not abandon/Reactivate. 


## Business assumptions:
1. Every time we update the snapshot table, we refer to the months that have ended. This is because we don't want to measure customer behavior in a month that hasn't ended yet. For example, it is possible that a customer did not have time to purchase this month and will purchase later, so we would not want to categorize him as “Abandoned “.
2. Since we are always looking at months that have ended, there is no point in updating the snapshot table every run during the month, because there will be no difference in the data. We do not refer to the current month, so the snapshot table will be updated once a month.



