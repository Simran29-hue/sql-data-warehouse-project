/*
=============================================================================
DDL Script: Create Bronze Tables
=============================================================================
Script Purpose:
   This script creates table in the 'bronze' schema, dropping existing tables 
   if they already exist.
   Run this script to re-define the DDL structure of 'bronze' Tables
==============================================================================
*/

if object_id ('bronze.crm_cust_info' , 'u')is not null
drop table bronze.crm_cust_info;
-- create table for cust_info csvv file 
create table bronze.crm_cust_info (
	cst_id INT,
	CST_KEY NVARCHAR(50),
	CST_FIRSTNAME NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_material_status NVARCHAR(50),
	cst_gender NVARCHAR(50),
	cst_create_date DATE
);

if object_id ('bronze.crm_prd_info' , 'u')is not null
drop table bronze.crm_prd_info;
-- create table for prd_info file 
Create table bronze.crm_prd_info(
prd_id	INT,
prd_key	NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATETIME,
prd_end_dt DATETIME
);


if object_id ('bronze.crm_sales_details' , 'u')is not null
drop table bronze.crm_sales_details;
--create table for sales_details
create table bronze.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales int,
sls_quantity int,
sls_price int
);


if object_id ('bronze.erp_loc_a101' , 'u')is not null
drop table bronze.erp_loc_a101;
create table bronze.erp_loc_a101(
cid NVARCHAR(50),
cntry NVARCHAR(50)
);


if object_id ('bronze.erp_cust_az12' , 'u')is not null
drop table bronze.erp_cust_az12;
create table bronze.erp_cust_az12(
cid NVARCHAR(50),
bdate Date,
gen NVARCHAR(50)
);


if object_id ('bronze.erp_px_cat_g1v2' , 'u')is not null
drop table bronze.erp_px_cat_g1v2;
create table bronze.erp_px_cat_g1v2 (
id NVARCHAR(50),
cat NVARCHAR(50),
subcat NVARCHAR(50),
maintenance NVARCHAR(50)
);
