/*
======================================================================
Stored procedure: Load Silver Layer (Bronnze -> Silver)
======================================================================
Script Purpose:
      This stored procedure perfforms the ETL (EXTRACT, TRANSFORM, LOAD) PROCESS TO 
    populated the 'silver' schema table from the 'Bronze' schema. 
    Action Performed: -
   - Truncate silver tables. 
    - Inserts transformed and cleaned data from Bronze into Silver1 tables.


Parameters:
     None.
This stored procedure does not accept any parameters or return any values.

Usage Example:
      EXEC silver1.load_silver1;
=========================================================================
*/

CREATE OR ALTER PROCEDURE silver1.load_silver1 AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Silver1 Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
PRINT '>> TRUNCATING TABLE : silver1.crm_cust_info';
TRUNCATE TABLE silver1.crm_cust_info;
PRINT '>> TRUNCATING TABLE : silver1.crm_cust_info';

INSERT INTO silver1.crm_cust_info (
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_marital_status, -- Normalize marital status values to readable format
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr, -- Normalize gender values to readable format
			cst_create_date
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

-- clean & load crm_prd_info
SET @start_time = GETDATE();
PRINT '>> TRUNCATING TABLE : silver1.crm_prd_info';
TRUNCATE TABLE silver1.crm_prd_info;
PRINT '>> TRUNCATING TABLE : silver1.crm_prd_info';

Insert into silver1.crm_prd_info (
      prd_id,
      cat_id,
      prd_key,
      prd_nm,
      prd_cost,
      prd_line,
      prd_start_dt,
      prd_end_dt
      )
select 
prd_id,
replace (substring(prd_key,1, 5), '-', '_') as cat_id,   -- extract category id
substring (prd_key, 7, len(prd_key)) as prd_key,         -- Extract pruoduct id
prd_nm,
ISNULL (prd_cost, 0) AS prd_cost,
case upper(trim(prd_line))
     when 'M' THEN 'Mountain'
     when 'R' THEN 'Road'
     when 'S' THEN 'Other Sales'
     when 'T' THEN 'Touring'
     else 'n/a'
END AS prd_line, -- map product line codes to descriptive values
CAST (prd_start_dt as date) as prd_start_dt,
cast(
    lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 
    as date
    ) as prd_end_dt -- Clacuate end date as one day before the next start date
from bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

-- clean & load crm_sales_details
SET @start_time = GETDATE();
PRINT '>> TRUNCATING TABLE : silver1.crm_sales_details';
TRUNCATE TABLE silver1.crm_sales_details;
PRINT '>> TRUNCATING TABLE : silver1.crm_sales_details';

Insert Into silver1.crm_sales_details (
  sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  sls_order_dt,
  sls_ship_dt,
  sls_due_dt,
  sls_sales,
  sls_quantity,
  sls_price
)
Select
sls_ord_num,
sls_prd_key,
sls_cust_id,
Case 
     when sls_order_dt = 0 or len (sls_order_dt) != 8 then null
     else cast(cast(sls_order_dt as varchar) as date)
END AS sls_order_dt,
Case 
     when sls_ship_dt = 0 or len (sls_ship_dt) != 8 then null
     else cast(cast(sls_ship_dt as varchar) as date)
END AS sls_ship_dt,
Case 
     when sls_due_dt = 0 or len (sls_due_dt) != 8 then null
     else cast(cast(sls_due_dt as varchar) as date)
END ASsls_due_dt,
Case 
     when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * ABS(sls_price)
	 THEN sls_quantity * ABS(sls_price)
	 ELSE sls_sales
END  AS sls_sales, -- Recalculate sales if original value is missing or incorrect
sls_quantity,
Case  
     when sls_price is null or sls_price <= 0
     then sls_sales / nullif(sls_quantity, 0)
     else sls_price   -- drive price if original value is in valid
End as sls_price
from bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

-- clean & load erp_cust_az12
SET @start_time = GETDATE();
PRINT '>> TRUNCATING TABLE : silver1.erp_cust_az12';
TRUNCATE TABLE silver1.erp_cust_az12;
PRINT '>> TRUNCATING TABLE : silver1.erp_cust_az12';

INSERT INTO silver1.erp_cust_az12(
cid,
bdate,
gen)
SELECT 
CASE 
	WHEN cid like 'NAS%' THEN SUBSTRING (cid, 4, len(cid)) -- remove 'NAS' prefix IFF PRESENT 
	ELSE cid
END cid, 
Case 
	when bdate > getdate() then NULL
	ELSE bdate
END as bdate, -- set future birthdates to null
CASE 
	 WHEN upper (TRIM (gen)) in ('F' , 'FEMALE') THEN 'Female'
     WHEN upper (TRIM (gen)) in ('M' , 'MALE') THEN 'Male'
     ELSE 'n/a'
END AS gen -- Normmalise gender values andd handle unknown cases
FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';



-- clean & load erp_loc_a101 
SET @start_time = GETDATE();
PRINT '>> TRUNCATING TABLE : silver1.erp_loc_a101';
TRUNCATE TABLE silver1.erp_loc_a101;
PRINT '>> TRUNCATING TABLE : silver1.erp_loc_a101';

INSERT INTO silver1.erp_loc_a101 
( cid, cntry)
SELECT 
REPLACE (cid, '-' , '') cid,
CASE 
     WHEN TRIM (cntry) = 'DE' THEN 'Germany'
     when TRIM (cntry) IN ('US' , 'USA') THEN 'United States'
     WHEN TRIM (cntry) =  '' OR cntry IS NULL THEN 'n/a'
     ELSE TRIM(cntry)
END AS cntry    -- NORMALISE AND HANDLE MISSING OR BLANK COUNTRY CODES
FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';


-- clean & load erp_px_cat_g1v2 
SET @start_time = GETDATE();
PRINT '>> TRUNCATING TABLE : silver1.erp_px_cat_g1v2';
TRUNCATE TABLE silver1.erp_px_cat_g1v2;
PRINT '>> TRUNCATING TABLE : silver1.erp_px_cat_g1v2';

Insert into silver1.erp_px_cat_g1v2 
(id, cat, subcat, maintenance)
SELECT 
id,
cat,
subcat,
maintenance
From bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';
		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver1 Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='

	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH

END
