CREATE INDEX IF NOT EXISTS idx_dw_customer_id_orders ON DWH_Fact_Product_In_Order(DW_customer_ID);
CREATE INDEX IF NOT EXISTS idx_dw_customer_id_events ON DWH_Fact_Events(DW_customer_ID);
CREATE INDEX IF NOT EXISTS idx_dw_customer_id_daily_Transactions ON Daily_Customers_Transactions(DW_customer_ID);
CREATE INDEX IF NOT EXISTS idx_dw_customer_id_daily_Purchase ON Daily_Purchase_Agg(DW_customer_ID);

