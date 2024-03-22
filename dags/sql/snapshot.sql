
CREATE OR REPLACE VIEW current_dates AS 
SELECT 
(DATE_TRUNC('MONTH', CURRENT_DATE) - INTERVAL '1 MONTH')::DATE AS StartOfPrevMonth,
(DATE_TRUNC('MONTH', CURRENT_DATE) - INTERVAL '1 DAY')::DATE AS EndOfPrevMonth,
EXTRACT(MONTH FROM DATE_TRUNC('month', (SELECT DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 day'))) AS PrevPeriodMonth,
EXTRACT(YEAR FROM DATE_TRUNC('month', (SELECT DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 day'))) AS PrevPeriodYear,
EXTRACT(QUARTER FROM DATE_TRUNC('month', (SELECT DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 day'))) AS PrevPeriodQuarter;

--cross join is fine beacuse the view consists of one record- the crrent date 
    CREATE OR REPLACE VIEW Snapshot_Customers_Transactions_month AS
    SELECT DISTINCT 
        cd.StartOfPrevMonth,
        c.Customer_ID,
        CASE 
            WHEN EXISTS (
                SELECT 1
                FROM DWH_Dim_Customers u
                WHERE u.Customer_ID = c.Customer_ID
                GROUP BY u.Customer_ID
                HAVING MIN(EXTRACT(MONTH FROM valid_from)) = cd.PrevPeriodMonth
                AND MIN(EXTRACT(YEAR FROM valid_from)) = cd.PrevPeriodYear
            ) THEN 'new'
            WHEN NOT EXISTS (
                SELECT 1
                FROM DWH_Dim_Customers t join DWH_Fact_Product_In_Order p
                ON p.DW_Customer_ID =t.DW_Customer_ID
                WHERE t.Customer_ID = c.Customer_ID 
                AND DATE(Order_Time) <= EndOfPrevMonth
                AND DATE(Order_Time) >= StartOfPrevMonth - INTERVAL '2 month'
            ) THEN 'abandoned'
            WHEN EXISTS (
                SELECT 1
                FROM Snapshot_Customers_Transactions_Arch s
                WHERE s.Customer_ID = c.Customer_ID 
                AND s.StartOfMonth = DATE(cd.StartOfPrevMonth) - INTERVAL '1 month'
                AND status ='abandoned' 
            ) 
             AND EXISTS (
                SELECT 1
                FROM DWH_Dim_Customers t join DWH_Fact_Product_In_Order p
                ON p.DW_Customer_ID = t.DW_Customer_ID
                WHERE t.Customer_ID = c.Customer_ID 
                AND DATE(Order_Time) <= cd.EndOfPrevMonth
                AND DATE(Order_Time) >= cd.StartOfPrevMonth
            ) THEN 'reactivated' 
            ELSE 'regular' 
        END AS Status
    FROM DWH_Dim_Customers c 
    CROSS JOIN current_dates cd; 
    
-- null cause we dont care about not null they belong to prev months 

  DO $$
BEGIN
IF (SELECT MAX(StartOfMonth) FROM Snapshot_Customers_Transactions_Arch) <
   (SELECT StartOfPrevMonth FROM current_dates) 
   
THEN
    -- Adding the new records to the archive table - incremental load
    -- Load to archive table and snapshot table only the previous month and load once only
    INSERT INTO Snapshot_Customers_Transactions_Arch (Customer_ID, StartOfMonth, Status)
    SELECT 
        Customer_ID,
        StartOfPrevMonth,
        Status 
    FROM Snapshot_Customers_Transactions_month t
    WHERE (Customer_ID,StartOfPrevMonth,Status) NOT IN (SELECT Customer_ID,StartOfPrevMonth,Status FROM Snapshot_Customers_Transactions_Arch);
    INSERT INTO DWH_Snapshot_Customers_Transactions (Year, Quarter, Month, Country, City, Count_New_Customers,
                                                     Count_Regular, Count_Reactivated, Count_Abandons, Count_Total)
    SELECT 
        PrevPeriodYear,
        PrevPeriodQuarter,
        PrevPeriodMonth,
        C.Country, 
        C.City,
        SUM(CASE WHEN A.Status='new' THEN 1 ELSE 0 END),
        SUM(CASE WHEN A.Status='regular' THEN 1 ELSE 0 END),
        SUM(CASE WHEN A.Status='reactivated' THEN 1 ELSE 0 END),
        SUM(CASE WHEN A.Status='abandoned' THEN 1 ELSE 0 END),
        COUNT(DISTINCT DW_Customer_ID) 
    FROM Snapshot_Customers_Transactions_Arch A JOIN DWH_Dim_Customers C 
    ON A.Customer_ID=C.Customer_ID
    WHERE (PrevPeriodYear,PrevPeriodQuarter,PrevPeriodMonth,C.Country, C.City) 
    NOT IN (SELECT PrevPeriodYear,PrevPeriodQuarter,PrevPeriodMonth,C.Country, C.City FROM DWH_Snapshot_Customers_Transactions)
    GROUP BY 
        PrevPeriodYear,
        PrevPeriodQuarter,
        PrevPeriodMonth,
        C.Country, 
        C.City;
ELSE
    RAISE NOTICE 'No records found for archiving.';
END IF;
END $$;