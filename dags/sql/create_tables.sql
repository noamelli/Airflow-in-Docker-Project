--MRR
CREATE TABLE IF NOT EXISTS MRR_Dim_Customers(
Customer_ID             varchar(50) null,
country             varchar(50) null,
currency            varchar(50) null,
exchange_to_usd     varchar(50) null,
installation_date   varchar(50) null,
media_source        varchar(50) null,
isValid             varchar(50) not null
);


CREATE TABLE IF NOT EXISTS MRR_Dim_Products(
product_ID          varchar(50) null,
product_name        varchar(50) null,
supplier            varchar(50) null,
category            varchar(50) null,
unit_price          varchar(50) null,
unit_cost           varchar(50) null,
isValid             varchar(50) not null
);


CREATE TABLE IF NOT EXISTS  MRR_Fact_Details(
order_ID            varchar(50) null,
product_ID          varchar(50) null,
quantity            varchar(50) null
);

CREATE TABLE IF NOT EXISTS  MRR_Fact_Orders(
order_ID            varchar(50) null,
order_time          varchar(50) null,
customer_ID         varchar(50) null,
coupon_discount     varchar(50) null
);

CREATE TABLE IF NOT EXISTS MRR_Fact_Events(
event_ID	        varchar(50)	not null,
event_description	varchar(50)	not null,
event_time	        varchar(50)	not null,
customer_ID	        varchar(50)	not null
);

--STG

CREATE TABLE IF NOT EXISTS  STG_Dim_Customers(
Customer_ID	            int	    not null,
country	            varchar(50)	not null,
currency	        varchar(50)	not null,
exchange_to_usd	    decimal(3,2)not null,
installation_date	date	    not null,
media_source	    varchar(50)	not null,
isValid	            varchar(50)	not null
);

CREATE TABLE IF NOT EXISTS  STG_Dim_Dates(
date	date	not null,
year	Int	    not null,
quarter	int	    not null,
month	int	    not null,
day	    int	    not null
);

CREATE TABLE IF NOT EXISTS STG_Dim_Products(
product_ID	    int	not         null,
product_name	varchar(50)	    not null,
supplier	    int	            not null,
category	    int	            not null,
unit_price	    decimal(15,5)	null,
unit_cost	    decimal(15,5)	null,
isValid	        varchar(10)	    not null
);

CREATE TABLE IF NOT EXISTS STG_Dim_Time(
dateTime	timestamp	not null,
date	    date	    not null,
hour	    int	        not null,
minute	    int	        not null
);


CREATE TABLE IF NOT EXISTS  STG_Fact_Details(
order_ID	int	not null,
product_ID	int	not null,
quantity	int	not null
);

CREATE TABLE IF NOT EXISTS  STG_Fact_Orders(
order_ID	    int	         not null,
order_time	    timestamp    not null,
customer_ID	    int	         not null,
coupon_discount	decimal(3,2) not null
);

CREATE TABLE IF NOT EXISTS STG_Fact_Events(
event_ID	        int	        not null,
event_description	varchar(50)	not null,
event_time	        timestamp	not null,
customer_ID	        int	        not null
);

---DWH 

CREATE TABLE IF NOT EXISTS DWH_Dim_Customers(
DW_customer_ID	    serial	    not null,
Customer_ID	        int	        not null,
country	            varchar(50)	not null,
currency	        varchar(50)	not null,
exchange_to_usd	    decimal(3,2) not null,
installation_date	date	    not null,
media_source	    varchar(50)	not null,
valid_from      	date default current_date null,
valid_until	        date	    null,
PRIMARY KEY (DW_customer_ID)
);


CREATE TABLE IF NOT EXISTS  DWH_Dim_Dates(
date	date	not null,
year	int	    not null,
quarter	int	    not null,
month	int	    not null,
day	    int	    not null,
PRIMARY KEY (date)
);


CREATE TABLE IF NOT EXISTS DWH_Dim_Products(
DW_product_ID	serial	    not null,
product_ID	    int	        not null,
product_name	varchar(50)	not null,
supplier	    int	        not null,
category	    int	        not null,
unit_price	    decimal(15,5)	null,
unit_cost	    decimal(15,5)	null,
valid_from 	    date default current_date null,
valid_until	    date	        null,
PRIMARY KEY (DW_product_ID)
);


CREATE TABLE IF NOT EXISTS DWH_Dim_Time(
dateTime	timestamp	not null,
date	    date	    not null,
hour	    int	        not null,
minute      int         not null,
PRIMARY KEY (dateTime )
); 

--DWH Fact tables - using partitions 

--DWH_Fact_Product_In_Order
CREATE TABLE IF NOT EXISTS DWH_Fact_Product_In_Order(
order_ID                    int             not null,
DW_product_ID               int             not null,
DW_customer_ID              int             not null,
order_time                  timestamp       not null,
country                     varchar(50)     not null,
currency                    varchar(50)     not null,
exchange_to_USD             decimal(3,2)    not null,
installation_date           date            not null,
media_source                varchar(50)     not null,
supplier                    int             not null,
category                    int             not null,
quantity                    int             null,
total_price_before_discount decimal(15,5)   not null,
total_cost                  decimal(15,5)   not null,
total_price_after_discount  decimal(15,5)   not null,
PRIMARY KEY (Order_ID, DW_product_ID, order_time) 
)  
PARTITION BY RANGE (order_time);



CREATE TABLE IF NOT EXISTS DWH_Fact_Events(
event_ID	        int	        not null,
event_description	varchar(50)	not null,
event_time	        timestamp	not null,
DW_customer_ID	    int	        not null,
country	            varchar(50)	not null,
currency	        varchar(50)	not null,
exchange_to_USD	    decimal(3,2)not null,
installation_date	date	    not null,
media_source	    varchar(50)	not null,
PRIMARY KEY (event_ID,event_time)
)
PARTITION BY RANGE (event_time);


--Summary tables 

CREATE TABLE IF NOT EXISTS Daily_Customers_Transactions(
DW_customer_ID	        int	        not null,
date	                date	    not null,
country	                varchar(50)	not null,
media_source	        varchar(50)	not null,
installation_date       date        not null,
last_seen 	            date	    not null,
last_order	            date	        null,
days_since_installation	int	        not null,
days_since_last_seen	int	        not null,
days_since_last_order	int	            null,
engagement_status	    varchar(50)	not null,
PRIMARY KEY (DW_customer_ID, date)
);


CREATE TABLE IF NOT EXISTS Daily_Purchase_Agg(
DW_customer_ID	    int	            not null,
order_date	        date 	        not null,
country	            varchar(50)	    not null,
supplier	        int	            not null,
category	        int	            not null,
media_source	    varchar(50)	    not null,
total_cost	        decimal(15,5)	not null,
total_quantity      int             not null, 
total_purchase_USD	decimal(15,5)	not null,
PRIMARY KEY (DW_customer_ID, order_date,supplier,category)
);

CREATE TABLE IF NOT EXISTS Daily_Event_Agg(
event_description	varchar(50)	not null,
event_date	        date 	    not null,
country	            varchar(50)	not null,
media_source	    varchar(50)	not null,
count 	            int	        not null,
PRIMARY KEY (event_description, event_date,country,media_source)
);


CREATE TABLE IF NOT EXISTS Monthly_Product_Rank(
DW_product_ID	            serial	    not null,
first_day_of_month	        date 	    not null,
category	                int	        not null,
number_of_orders            int	        not null,
total_quantity              int	        not null,
net_profit                  int	        not null,
orders_percent_rank 	decimal(15,5)	not null,
quantity_percent_rank	decimal(15,5)	not null,
profit_percent_rank 	decimal(15,5)	not null,
PRIMARY KEY (DW_product_ID, first_day_of_month)
);

CREATE TABLE IF NOT EXISTS Monthly_Supplier_Rank(
category	                int	        not null,
first_day_of_month	        date        not null,
supplier 	                int	        not null,
number_of_orders            int	        not null,
total_quantity              int	        not null,
net_profit                  int	        not null,
orders_percent_rank 	decimal(15,5)	not null,
quantity_percent_rank	decimal(15,5)	not null,
profit_percent_rank 	decimal(15,5)	not null,
PRIMARY KEY (category, first_day_of_month, supplier)
);

--backup

CREATE TABLE IF NOT EXISTS DWH_Dim_Customers_backup(
DW_customer_ID	    serial	    not null,
Customer_ID	            int	        not null,
country	            varchar(50)	not null,
currency	        varchar(50)	not null,
exchange_to_usd	    decimal(3,2) not null,
installation_date	date	    not null,
media_source	    varchar(50)	not null,
valid_from      	date	    null,
valid_until	        date	    null,
PRIMARY KEY (DW_customer_ID)
);


CREATE TABLE IF NOT EXISTS DWH_Dim_Products_backup(
DW_product_ID	serial	    not null,
product_ID	    int	        not null,
product_name	varchar(50)	not null,
supplier	    int	        not null,
category	    int	        not null,
unit_price	    decimal(15,5)	null,
unit_cost	    decimal(15,5)	null,
valid_from 	    date	        null,
valid_until	    date	        null,
PRIMARY KEY (DW_product_ID)
);



CREATE TABLE IF NOT EXISTS DWH_Fact_Product_In_Order_backup(
order_ID	            int	            not null,
DW_product_ID	        int	            not null,
DW_customer_ID	        int	            not null,
order_time	            timestamp	    not null,
country	                varchar(50)	    not null,
currency	            varchar(50)	    not null,
exchange_to_USD	        decimal(3,2)    not null,
installation_date	    date	        not null,
media_source	        varchar(50)	    not null,
supplier	            int	            not null,
category	            int	            not null,
quantity	            int	                null,
total_price_before_discount  decimal(15,5)  not null,
total_cost	                 decimal(15,5)   not null,
total_price_after_discount	 decimal(15,5)	not null,
PRIMARY KEY (Order_ID, DW_product_ID)
);

CREATE TABLE IF NOT EXISTS DWH_Fact_Events_backup(
event_ID	        int	        not null,
event_description	varchar(50)	not null,
event_time	        timestamp	not null,
DW_customer_ID	    int	        not null,
country	            varchar(50)	not null,
currency	        varchar(50)	not null,
exchange_to_USD	    decimal(3,2)not null,
installation_date	date	    not null,
media_source	    varchar(50)	not null,
PRIMARY KEY (event_ID)
);

CREATE TABLE IF NOT EXISTS Daily_Customers_Transactions_backup(
DW_customer_ID	        int	        not null,
date	                date	    not null,
country	                varchar(50)	not null,
media_source	        varchar(50)	not null,
installation_date       date        not null,
last_seen 	            date	    not null,
last_order	            date	        null,
days_since_installation	int	        not null,
days_since_last_seen	int	        not null,
days_since_last_order	int	            null,
engagement_status	    varchar(50)	not null,
PRIMARY KEY (DW_customer_ID, date)
);

CREATE TABLE IF NOT EXISTS Daily_Purchase_Agg_backup(
DW_customer_ID	    int	            not null,
order_date	        date 	        not null,
country	            varchar(50)	    not null,
supplier	        int	            not null,
category	        int	            not null,
media_source	    varchar(50)	    not null,
total_cost	        decimal(15,5)	not null,
total_quantity      int             not null, 
total_purchase_USD	decimal(15,5)	not null,
PRIMARY KEY (DW_customer_ID, order_date, supplier, category)
);

CREATE TABLE IF NOT EXISTS Daily_Event_Agg_backup(
event_description	varchar(50)	not null,
event_date	        date 	    not null,
country	            varchar(50)	not null,
media_source	    varchar(50)	not null,
count 	            int	        not null,
PRIMARY KEY (event_description, event_date,country,media_source)
);


CREATE TABLE IF NOT EXISTS Monthly_Product_Rank_backup(
DW_product_ID	            serial	    not null,
first_day_of_month	        date 	    not null,
category	                int	        not null,
number_of_orders            int	        not null,
total_quantity              int	        not null,
net_profit                  int	        not null,
orders_percent_rank 	decimal(15,5)	not null,
quantity_percent_rank	decimal(15,5)	not null,
profit_percent_rank 	decimal(15,5)	not null,
PRIMARY KEY (DW_product_ID, first_day_of_month)
);

CREATE TABLE IF NOT EXISTS Monthly_Supplier_Rank_backup(
category	                int	        not null,
first_day_of_month	        date        not null,
supplier 	                int	        not null,
number_of_orders            int	        not null,
total_quantity              int	        not null,
net_profit                  int	        not null,
orders_percent_rank 	decimal(15,5)	not null,
quantity_percent_rank	decimal(15,5)	not null,
profit_percent_rank 	decimal(15,5)	not null,
PRIMARY KEY (category, first_day_of_month, supplier)
);