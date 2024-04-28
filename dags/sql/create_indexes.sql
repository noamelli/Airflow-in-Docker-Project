CREATE INDEX IF NOT EXISTS idx_dw_customer_id_orders ON DWH_Fact_Product_In_Order(DW_customer_ID);
CREATE INDEX IF NOT EXISTS idx_dw_customer_id_events ON DWH_Fact_Events(DW_customer_ID);
 
