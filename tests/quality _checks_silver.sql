/* 
===================================================================
Quality Checks
===================================================================
Script Purpose:
      This script performs various quality checks for data consistency, accuracy, 
      standarisation acroos the 'silver1' schema . it includes checks for:
      - Null or duplicate primary keys.
      - Unwanted spaces in string fields. 
      - data standardisation and consistency.
      - invalid data range and orders.
      - Data consisitency between related fields.

Usage Notes:
      - Run these checks after data loading silver1 layer.
      - Investigate and resolve any discrepancies found during the checks.
===================================================================

*/
-- check for unwanted spaces
-- expectation: no results
select prd_nm
from silver1.crm_prd_info
where prd_nm != trim(prd_nm)


-- check for nulls or negative numbers
--expecctation: no results
select prd_cost
from silver1.crm_prd_info
where prd_cost< 0 or prd_cost is null

-- data standarlisation & consistency
select distinct prd_line 
from silver1.crm_prd_info

-- check for Invalid Date Orders
select *
from silver1.crm_prd_info
where prd_end_dt < prd_start_dt

-- check for invalid dates
select
NULLIF(sls_order_dt, 0) sls_order_dt
from silver1.crm_sales_details
where sls_order_dt <= 0 
or len(sls_order_dt) != 8 
or sls_order_dt > 20500101 
or sls_order_dt > 19000101

-- check for Invalid Date Orders
select *
from silver1.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt


-- check  data cconsistency: between sales , quantity, and price
-- .. sales = quantity * price
-- >> valuues must not be null, zero or negative
select distinct
sls_sales as old_sls_sales,
sls_quantity,
sls_price as old_sls_price,
case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
	 THEN sls_quantity * ABS(sls_price)
	 ELSE sls_sales
END  AS sls_sales,
case when sls_price is null or sls_price <= 0
then sls_sales / nullif(sls_quantity, 0)
else sls_price
end as sls_price
from silver1.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null  or sls_quantity is null or sls_price is null
or sls_sales <= 0   or sls_quantity <= 0 or sls_price <= 0
order by sls_sales, sls_quantity,  sls_price

-- IDENTIFY OUUT-OF RANGE DATES

SELECT DISTINCT
BDATE
FROM silver1.erp_cust_az12
WHERE  bdate<'1924-01-01' or bdate > getdate()

-- data standardisation & consistency
select distinct gen
From silver1.erp_cust_az12
