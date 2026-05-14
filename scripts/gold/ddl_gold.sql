/*
=========================================================================
DDL Script: CREATE GOLD VIEWS
=========================================================================
SCRIPT PURPOSE :
THIS SCRIPT CREATES VIEWS FOR THE GOLD LAYER IN THE DATA WAREHOUSE.
THE GOLD LAYER REPRESENTS THE FINAL DIMENSION AND FACT TABLES (STAR SCHEMA)

EACH VIEW PERFORMS TRANSFORMATIONS AND COMBINE DATA FROM THE SILVER LAYER
TO PRODUCE A CLEAN , ENRICHED, AND BUSINESS-READY DATASET.

USAGE:
     - THESE VIEWS CAN BE QUERIED DIRECTLY FOR DATA ANALYTICS AND REPORTING.
============================================================================
*/

--======================================================
-- CREATE DIMENSION TABLE: gold.dim_customers
--======================================================
If OBJECT _ID('gold.dim_customers' , 'V') IS NOT NULL
   DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers as 
select 
ROW_NUMBER() OVER (ORDER BY cst_id) as customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
la.cntry as country,
ci.cst_marital_status as marital_status,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr -- crm is the master for gender info
ELSE coalesce (ca.gen, 'n/a')
END AS gender,
ca.bdate as birthdate,
ci.cst_create_date as create_date
FROM silver1.crm_cust_info ci
left join silver1.erp_cust_az12 ca
on ci.cst_key = ca.cid
left join silver1.erp_loc_a101 la
on ci.cst_key = la.cid;
go

--======================================================
-- CREATE DIMENSION TABLE: gold.dim_product
--======================================================
If OBJECT _ID('gold.dim_product' , 'V') IS NOT NULL
   DROP VIEW gold.dim_product;
GO
  
CREATE VIEW gold.dim_product as 
select 
ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
From silver1.crm_prd_info pn
left join silver1.erp_px_cat_g1v2 pc
on pn.cat_id = pc.id
where prd_end_dt is null -- filter out all historical data;
go

--======================================================
-- CREATE FACT TABLE: gold.fact_sales
--======================================================
If OBJECT _ID('gold.fact_sales' , 'V') IS NOT NULL
   DROP VIEW gold.fact_sales;
GO
  
CREATE VIEW gold.fact_sales as 
SELECT 
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as pricce
FROM silver1.crm_sales_details sd
left join  gold.dim_product pr
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers cu
on sd.sls_cust_id = cu.customer_id;
GO
