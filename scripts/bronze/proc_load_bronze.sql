/*
==================================================================
stored procedure: Load Bronze Layer (source-> Bronze)
==================================================================
Script Purpose:
   This stored procedure loads data into the 'bronze' schema from external CSV files.
   It performs the following action:
    - Truncate the bronze tables before loadiong data.
    - Uses the 'Bulk Insert command to load data from csv files to Bronze table.

Parameters:
     None 
    This stored procedure does not acceptt any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
=====================================================================
*/


create or alter procedure bronze.load_bronze as 
BEGIN
DECLARE @START_TIME DATETIME, @END_TIME DATETIME; DECLARE @BATCH_START_TIME DATETIME, @BATCH_END_TIME DATETIME;
BEGIN TRY
SET @BATCH_START_TIME = GETDATE();
PRINT '================================';
PRINT 'LOADING BRONZE LAYER';
PRINT '================================';

PRINT '--------------------------------';
PRINT 'LOADING CRM TABLE';
PRINT '--------------------------------';

SET @START_TIME = GETDATE();
PRINT '>>TRUNCATING TABLE : bronze.crm_cust_info';
	TRUNCATE TABLE bronze.crm_cust_info;

PRINT 'INSERTING DATA INTO : bronze.crm_cust_info';
	BULK INSERT bronze.crm_cust_info
	FROM 'C:\Users\Simran\OneDrive\SQL SERVER\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	with (
	firstrow = 2,
	fieldterminator = ',' ,
	tablock
	);
SET @END_TIME = GETDATE();
PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(SECOND,@START_TIME, @END_TIME) AS NVARCHAR) + 'SECONDS';
PRINT '>>------------------'

SET @START_TIME = GETDATE();
PRINT '>>TRUNCATING TABLE : bronze.crm_prd_info';
	TRUNCATE TABLE bronze.crm_prd_info;

PRINT 'INSERTING DATA INTO : bronze.crm_prd_info';
	BULK INSERT bronze.crm_prd_info
	FROM 'C:\Users\Simran\OneDrive\SQL SERVER\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	with (
	firstrow = 2,
	fieldterminator = ',' ,
	tablock
	);
SET @END_TIME = GETDATE();
PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(SECOND,@START_TIME, @END_TIME) AS NVARCHAR) + 'SECONDS';
PRINT '>>------------------'

SET @START_TIME = GETDATE();
PRINT '>>TRUNCATING TABLE : bronze.crm_sales_details';
	TRUNCATE TABLE bronze.crm_sales_details;

PRINT 'INSERTING DATA INTO : bronze.crm_sales_details';
	BULK INSERT bronze.crm_sales_details
	FROM 'C:\Users\Simran\OneDrive\SQL SERVER\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	with (
	firstrow = 2,
	fieldterminator = ',' ,
	tablock
	);
SET @END_TIME = GETDATE();
PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(SECOND,@START_TIME, @END_TIME) AS NVARCHAR) + 'SECONDS';
PRINT '>>------------------'

PRINT '--------------------------------';
PRINT 'LOADING ERP TABLE';
PRINT '--------------------------------';

SET @START_TIME = GETDATE();
PRINT '>>TRUNCATING TABLE : bronze.erp_loc_a101';
	TRUNCATE TABLE bronze.erp_loc_a101;

PRINT 'INSERTING DATA INTO : bronze.erp_loc_a101';
	BULK INSERT bronze.erp_loc_a101
	FROM 'C:\Users\Simran\OneDrive\SQL SERVER\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
	with (
	firstrow = 2,
	fieldterminator = ',' ,
	tablock
	);
SET @END_TIME = GETDATE();
PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(SECOND,@START_TIME, @END_TIME) AS NVARCHAR) + 'SECONDS';
PRINT '>>------------------'


SET @START_TIME = GETDATE();
PRINT '>>TRUNCATING TABLE : bronze.erp_cust_az12';
	TRUNCATE TABLE bronze.erp_cust_az12;

PRINT 'INSERTING DATA INTO : bronze.erp_cust_az12';
	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\Users\Simran\OneDrive\SQL SERVER\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
	with (
	firstrow = 2,
	fieldterminator = ',' ,
	tablock
	);
SET @END_TIME = GETDATE();
PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(SECOND,@START_TIME, @END_TIME) AS NVARCHAR) + 'SECONDS';
PRINT '>>------------------'


SET @START_TIME = GETDATE();
PRINT '>>TRUNCATING TABLE : bronze.erp_px_cat_g1v2';
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;

PRINT 'INSERTING DATA INTO : bronze.erp_px_cat_g1v2';
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'C:\Users\Simran\OneDrive\SQL SERVER\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
	with (
	firstrow = 2,
	fieldterminator = ',' ,
	tablock
	);
SET @END_TIME = GETDATE();
PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(SECOND,@START_TIME, @END_TIME) AS NVARCHAR) + 'SECONDS';
PRINT '>>------------------'

SET @BATCH_END_TIME = GETDATE();
PRINT '========================================================'
PRINT 'LOADING BRONZE LAYER IS COMPLETED';
PRINT '   - TOTAL LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @BATCH_START_TIME, @BATCH_END_TIME) AS NVARCHAR) + 'SECONDS';
PRINT '========================================================'
END TRY
BEGIN CATCH
PRINT '========================================================'
PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
PRINT 'ERROR MESSAGE' + CAST (ERROR_NUMBER() AS NVARCHAR);
PRINT 'ERROR MESSAGE' + CAST (ERROR_STATE() AS NVARCHAR);
PRINT '========================================================'
END CATCH
END
