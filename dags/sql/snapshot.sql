--The rellevant perdios for loading are months that have been ended and have not been loaded yet 
CREATE OR REPLACE VIEW relevant_periods AS 
SELECT DISTINCT 
(DATE_TRUNC('MONTH', order_time))::DATE AS StartOfMonth,
(DATE_TRUNC('MONTH', order_time) + INTERVAL '1 month' - INTERVAL '1 day')::DATE AS EndOfMonth
FROM dwh_fact_product_in_order
WHERE (DATE_TRUNC('MONTH', order_time))::DATE NOT IN  
                    (SELECT DISTINCT StartOfMonth
                     FROM Snapshot_Customers_Transactions_Arch)
AND (DATE_TRUNC('MONTH', order_time))::DATE <> (DATE_TRUNC('MONTH', CURRENT_DATE))::DATE    ; 



    CREATE OR REPLACE VIEW status_calculation AS
    SELECT DISTINCT 
        cd.StartOfMonth,
        c.DW_Customer_ID,
        C.Customer_ID,
        CASE 
            WHEN EXISTS (
                SELECT 1
                FROM DWH_Dim_Customers t join DWH_Fact_Product_In_Order p
                ON p.DW_Customer_ID =t.DW_Customer_ID
                WHERE t.Customer_ID = c.Customer_ID
                GROUP BY t.Customer_ID
                HAVING MIN ((DATE_TRUNC('MONTH', p.order_time))::DATE) = cd.StartOfMonth
            ) THEN 'new'
            WHEN NOT EXISTS (
                SELECT 1
                FROM DWH_Dim_Customers t join DWH_Fact_Product_In_Order p
                ON p.DW_Customer_ID =t.DW_Customer_ID
                WHERE t.Customer_ID = c.Customer_ID 
                AND DATE(Order_Time) <= cd.EndOfMonth
                AND DATE(Order_Time) >= cd.StartOfMonth - INTERVAL '2 month'
            ) THEN 'abandoned'
            WHEN EXISTS (
                SELECT 1
                FROM Snapshot_Customers_Transactions_Arch s
                WHERE s.Customer_ID = c.Customer_ID 
                AND s.StartOfMonth = DATE(cd.StartOfMonth) - INTERVAL '1 month'
                AND status ='abandoned' 
            ) 
             AND EXISTS (
                SELECT 1
                FROM DWH_Dim_Customers t join DWH_Fact_Product_In_Order p
                ON p.DW_Customer_ID = t.DW_Customer_ID
                WHERE t.Customer_ID = c.Customer_ID 
                AND DATE(Order_Time) <= cd.EndOfMonth
                AND DATE(Order_Time) >= cd.StartOfMonth
            ) THEN 'reactivated' 
            ELSE 'regular' 
        END AS Status
    FROM DWH_Dim_Customers c
    CROSS JOIN relevant_periods cd -- Showing all the optional combinations 
    WHERE c.Valid_Until IS NULL ; 


    -- Adding the new records to the archive table - it contains historical data beacuse this data is being used in status_calculation table 
    INSERT INTO Snapshot_Customers_Transactions_Arch (DW_Customer_ID, Customer_ID, StartOfMonth, Status)
    SELECT 
        DW_Customer_ID,
        Customer_ID,
        StartOfMonth,
        Status 
    FROM status_calculation t ; 

    
    --Using incremental loading because we Snapshot_Customers_Transactions_Arch contains historical data 
    INSERT INTO DWH_Snapshot_Customers_Transactions (Year, Quarter, Month, Country, Count_New_Customers,
                                                     Count_Regular, Count_Reactivated, Count_Abandons, Count_Total)
    SELECT 
    EXTRACT (year from StartOfMonth),
    EXTRACT (Quarter from StartOfMonth),
    EXTRACT (month from StartOfMonth),
    C.Country, 
    SUM(CASE WHEN A.Status='new' THEN 1 ELSE 0 END),
    SUM(CASE WHEN A.Status='regular' THEN 1 ELSE 0 END),
    SUM(CASE WHEN A.Status='reactivated' THEN 1 ELSE 0 END),
    SUM(CASE WHEN A.Status='abandoned' THEN 1 ELSE 0 END),
    COUNT(DISTINCT A.DW_Customer_ID) 
    FROM Snapshot_Customers_Transactions_Arch A JOIN DWH_Dim_Customers C 
    ON A.DW_Customer_ID=C.DW_Customer_ID
    WHERE (EXTRACT (year from StartOfMonth),EXTRACT (Quarter from StartOfMonth),EXTRACT (month from StartOfMonth),C.Country, C.City) 
    NOT IN (select distinct Year,Quarter,month,Country, City FROM DWH_Snapshot_Customers_Transactions)
    GROUP BY 
    EXTRACT (year from StartOfMonth),
    EXTRACT (Quarter from StartOfMonth),
    EXTRACT (month from StartOfMonth),
    C.Country;


