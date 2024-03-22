CREATE TABLE IF NOT EXISTS MRR_Dim_Customers(
    Customer_ID varchar(50) null,
    Company_Name varchar(50) null,
    Contact_Name varchar(50) null,
    Street varchar(50) null,
    City varchar(50) null,
    Postal_Code varchar(50) null,
    Country varchar(50) null,
    Phone varchar(50) null,
    Fax varchar(50) null
);

CREATE TABLE IF NOT EXISTS MRR_Dim_Employees(
    Employee_ID varchar(50) null,
    Last_Name varchar(50) null,
    First_Name varchar(50) null,
    Title varchar(50) null,
    Hire_Date varchar(50) null,
    Office varchar(50) null,
    Reports_To varchar(50) null,
    Month_Salary varchar(50) null
);

CREATE TABLE IF NOT EXISTS MRR_Dim_Products(
    Product_ID varchar(50) null,
    Product_Name varchar(50) null,
    Supplier varchar(50) null,
    Category varchar(50) null,
    Unit_Price varchar(50) null,
    Unit_Cost varchar(50) null
);

CREATE TABLE IF NOT EXISTS  MRR_Fact_Details(
    Order_ID varchar(50) null,
    Product_ID varchar(50) null,
    Quantity varchar(50) null
);
CREATE TABLE IF NOT EXISTS  MRR_Fact_Orders(
    Order_ID varchar(50) null,
    Order_Time varchar(50) null,
    Customer_ID varchar(50) null,
    Employee_ID varchar(50) null,
    Shipper_ID varchar(50) null
);

CREATE TABLE IF NOT EXISTS  STG_Dim_Customers(
    Customer_ID int not null,
    Company_Name varchar(50) not null,
    Contact_Name varchar(50) not null,
    Street varchar(50) not null,
    City varchar(50) not null,
    Postal_Code varchar(50) not null,
    Country varchar(50) not null,
    Phone varchar(50) not null,
    Fax varchar(50) not null,
    PRIMARY KEY (Customer_ID)
);

CREATE TABLE IF NOT EXISTS  STG_Dim_Dates(
    Date date not null,
    Year int not null,
    Quarter int not null,
    Month int not null,
    Day int not null,
    PRIMARY KEY (Date)
);

CREATE TABLE IF NOT EXISTS  STG_Dim_Employees(
    Employee_ID int not null,
    Last_Name varchar(50) not null,
    First_Name varchar(50) not null,
    Title varchar(50) not null,
    Hire_Date date not null,
    Office int not null,
    Reports_To int null,
    Month_Salary decimal(15,5) null,
    PRIMARY KEY (Employee_ID)
);


CREATE TABLE IF NOT EXISTS STG_Dim_Products(
    Product_ID int not null,
    Product_Name varchar(50) not null,
    Supplier int not null,
    Category int not null,
    Unit_Price decimal(15,5) null,
    Unit_Cost decimal(15,5) null,
    PRIMARY KEY (Product_ID)
);

CREATE TABLE IF NOT EXISTS STG_Dim_Time(
    DateTime  timestamp  not null,
    Date date not null,
    Hour time (7) not null,
    PRIMARY KEY (DateTime )
);


CREATE TABLE IF NOT EXISTS  STG_Fact_Details(
    Order_ID int not null,
    Product_ID int not null,
    Quantity int null
);
CREATE TABLE IF NOT EXISTS  STG_Fact_Orders(
    Order_ID int not null,
    Order_Time timestamp not null,
    Customer_ID int not null,
    Employee_ID int not null,
    Shipper_ID int not null
);


CREATE TABLE IF NOT EXISTS DWH_Dim_Customers(
    DW_Customer_ID serial not null,
    Customer_ID int not null,
    Company_Name varchar(50) not null,
    Contact_Name varchar(50) not null,
    Street varchar(50) not null,
    City varchar(50) not null,
    Postal_Code varchar(50) not null,
    Country varchar(50) not null,
    Phone varchar(50) not null,
    Fax varchar(50) not null,
    Valid_From date not null default current_date,
    Valid_Until date null,
    PRIMARY KEY (DW_Customer_ID)
);


CREATE TABLE IF NOT EXISTS  DWH_Dim_Dates(
    Date date not null,
    Year int not null,
    Quarter int not null,
    Month int not null,
    Day int not null,
    PRIMARY KEY (Date)
);


CREATE TABLE IF NOT EXISTS DWH_Dim_Employees(
    DW_Employee_ID serial not null,
    Employee_ID int not null,
    Last_Name varchar(50) not null,
    First_Name varchar(50) not null,
    Title varchar(50) not null,
    Hire_Date date not null,
    Office int not null,
    Reports_To int null,
    Month_Salary decimal(15,5) null,
    Valid_From date not null default current_date,
    Valid_Until date null,
    PRIMARY KEY (DW_Employee_ID)
);


CREATE TABLE IF NOT EXISTS DWH_Dim_Products(
    DW_Prdocut_ID serial not null,
    Product_ID int not null,
    Product_Name varchar(50) not null,
    Supplier int not null,
    Category int not null,
    Unit_Price decimal(15,5) null,
    Unit_Cost decimal(15,5)  null,
    Valid_From date not null default current_date,
    Valid_Until date null,
    PRIMARY KEY (DW_Prdocut_ID)
);


CREATE TABLE IF NOT EXISTS DWH_Fact_Product_In_Order(
    Order_ID int not null,
    DW_Prdocut_ID int not null,
    DW_Customer_ID int not null,
    DW_Employee_ID int not null,
    Order_Time timestamp not null,
    Quantity int null,
    Total_Price decimal(15,5) not null,
    Total_Cost decimal(15,5) not null,
    Shipper_ID int not null,
    PRIMARY KEY (Order_ID, DW_Prdocut_ID)
);


CREATE TABLE IF NOT EXISTS DWH_Dim_Time(
    DateTime  timestamp  not null,
    Date date not null,
    Hour time(7) not null,
    PRIMARY KEY (DateTime )
);

CREATE TABLE IF NOT EXISTS Snapshot_Customers_Transactions_Arch(
    Customer_ID int not null,
    StartOfMonth date not null,
    Status varchar(10) not null
);

CREATE TABLE IF NOT EXISTS DWH_Snapshot_Customers_Transactions(
    Year int not null,
    Quarter int not null,
    Month int not null,
    Country varchar(50) not null,
    City varchar(50) not null,
    Count_New_Customers int not null,
    Count_Regular int not null,
    Count_Reactivated int not null,
    Count_Abandons int not null,
    Count_Total int not null,
    PRIMARY KEY (Year, Quarter, Month, Country, City)
);

CREATE TABLE IF NOT EXISTS DWH_Dim_Customers_backup(
    DW_Customer_ID serial not null,
    Customer_ID int not null,
    Company_Name varchar(50) not null,
    Contact_Name varchar(50) not null,
    Street varchar(50) not null,
    City varchar(50) not null,
    Postal_Code varchar(50) not null,
    Country varchar(50) not null,
    Phone varchar(50) not null,
    Fax varchar(50) not null,
    Valid_From date not null default current_date,
    Valid_Until date null,
    PRIMARY KEY (DW_Customer_ID)
);


CREATE TABLE IF NOT EXISTS  DWH_Dim_Dates_backup(
    Date date not null,
    Year int not null,
    Quarter int not null,
    Month int not null,
    Day int not null,
    PRIMARY KEY (Date)
);


CREATE TABLE IF NOT EXISTS DWH_Dim_Employees_backup(
    DW_Employee_ID serial not null,
    Employee_ID int not null,
    Last_Name varchar(50) not null,
    First_Name varchar(50) not null,
    Title varchar(50) not null,
    Hire_Date date not null,
    Office int not null,
    Reports_To int null,
    Month_Salary decimal(15,5) null,
    Valid_From date not null default current_date,
    Valid_Until date null,
    PRIMARY KEY (DW_Employee_ID)
);


CREATE TABLE IF NOT EXISTS DWH_Dim_Products_backup(
    DW_Prdocut_ID serial not null,
    Product_ID int not null,
    Product_Name varchar(50) not null,
    Supplier int not null,
    Category int not null,
    Unit_Price decimal(15,5) null,
    Unit_Cost decimal(15,5)  null,
    Valid_From date not null default current_date,
    Valid_Until date null,
    PRIMARY KEY (DW_Prdocut_ID)
);


CREATE TABLE IF NOT EXISTS DWH_Fact_Product_In_Order_backup(
    Order_ID int not null,
    DW_Prdocut_ID int not null,
    DW_Customer_ID int not null,
    DW_Employee_ID int not null,
    Order_Time timestamp not null,
    Quantity int null,
    Total_Price decimal(15,5) not null,
    Total_Cost decimal(15,5) not null,
    Shipper_ID int not null,
    PRIMARY KEY (Order_ID, DW_Prdocut_ID)
);


CREATE TABLE IF NOT EXISTS DWH_Dim_Time_backup(
    timestamp  timestamp  not null,
    Date date not null,
    Hour time(7) not null,
    PRIMARY KEY (timestamp )
);


CREATE TABLE IF NOT EXISTS DWH_Snapshot_Customers_Transactions_backup(
    Year int not null,
    Quarter int not null,
    Month int not null,
    Country varchar(50) not null,
    City varchar(50) not null,
    Count_New_Customers int not null,
    Count_Regular int not null,
    Count_Reactivated int not null,
    Count_Abandons int not null,
    Count_Total int not null,
    PRIMARY KEY (Year, Quarter, Month, Country, City)
);








