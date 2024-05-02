--product_in_order partitions
-- Create the default partition
CREATE TABLE IF NOT EXISTS products_in_orders_default PARTITION OF DWH_Fact_Product_In_Order
    DEFAULT;

-- Create the future partition to cover all future values
CREATE TABLE IF NOT EXISTS products_in_orders_future PARTITION OF DWH_Fact_Product_In_Order
    FOR VALUES FROM (DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year') TO (MAXVALUE);


-- Create a function to generate partition names
CREATE OR REPLACE FUNCTION generate_partition_name(date) RETURNS TEXT AS $$
BEGIN
    RETURN 'products_in_orders_' || to_char($1, 'YYYY_q');
END;
$$ LANGUAGE plpgsql;

-- Create a function to create products in orders partitions automatically
CREATE OR REPLACE FUNCTION create_products_in_orders_partitions() RETURNS VOID AS $$
DECLARE
    start_date DATE := DATE_TRUNC('year', CURRENT_DATE);
    end_date DATE := DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year';
    quarter_start DATE;
    quarter_end DATE;
BEGIN
    WHILE start_date < end_date LOOP
        quarter_start := start_date;
        quarter_end := start_date + INTERVAL '3 months';

        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I PARTITION OF DWH_Fact_Product_In_Order
            FOR VALUES FROM (%L) TO (%L);
        ', generate_partition_name(quarter_start), quarter_start, quarter_end);

        start_date := quarter_end;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Call the function to create products in orders partitions
SELECT create_products_in_orders_partitions();


--events partitions
-- Create the default partition
CREATE TABLE IF NOT EXISTS events_default PARTITION OF DWH_Fact_Events
    DEFAULT;

-- Create the future partition to cover all future values
CREATE TABLE IF NOT EXISTS events_future PARTITION OF DWH_Fact_Events
    FOR VALUES FROM (DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year') TO (MAXVALUE);


-- Create a function to generate partition names
CREATE OR REPLACE FUNCTION generate_partition_name(date) RETURNS TEXT AS $$
BEGIN
    RETURN 'events_' || to_char($1, 'YYYY_q');
END;
$$ LANGUAGE plpgsql;

-- Create a function to create events partitions automatically
CREATE OR REPLACE FUNCTION create_events_partitions() RETURNS VOID AS $$
DECLARE
    start_date DATE := DATE_TRUNC('year', CURRENT_DATE);
    end_date DATE := DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year';
    quarter_start DATE;
    quarter_end DATE;
BEGIN
    WHILE start_date < end_date LOOP
        quarter_start := start_date;
        quarter_end := start_date + INTERVAL '3 months';

        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I PARTITION OF DWH_Fact_Events
            FOR VALUES FROM (%L) TO (%L);
        ', generate_partition_name(quarter_start), quarter_start, quarter_end);

        start_date := quarter_end;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Call the function to create quarterly partitions
SELECT create_events_partitions();
