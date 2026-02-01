/*
Warning: This script loads bronze layer info by TRUNCATING existing tables and INSERTING data from the source system.
*/
CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
	BEGIN TRY
		PRINT '===================================================================='
		PRINT 'Loading Bronze Layer'
		PRINT '===================================================================='

		PRINT '--------------------------------------------------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '--------------------------------------------------------------------'

		PRINT '>> Loading Table: crm_cust_info'
		TRUNCATE TABLE Bronze.crm_cust_info
		BULK INSERT Bronze.crm_cust_info
		FROM 'C:\Users\asmaa\Downloads\SQL Course\SQL-Data-Warehouse\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		IF (SELECT COUNT(*) FROM Bronze.crm_cust_info) = 18493
			PRINT 'All Rows  Loaded Successfully'
		ELSE
			PRINT 'Row Loading Integrity Compromised'
		IF (SELECT cst_lastname FROM Bronze.crm_cust_info WHERE cst_id = 11029) = 'Moreno'
			PRINT 'Column Order Retained'
		ELSE
			PRINT 'Column Order Compromised'
		PRINT ''
		------------------------------------------------------------------------------------------------
		PRINT '>> Loading Table: crm_prd_info'
		TRUNCATE TABLE Bronze.crm_prd_info
		BULK INSERT Bronze.crm_prd_info
		FROM 'C:\Users\asmaa\Downloads\SQL Course\SQL-Data-Warehouse\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		IF (SELECT COUNT(*) FROM Bronze.crm_prd_info) = 397
			PRINT 'All Rows  Loaded Successfully'
		ELSE
			PRINT 'Row Loading Integrity Compromised'
		IF (SELECT prd_cost FROM Bronze.crm_prd_info WHERE prd_id = 233) = 29
			PRINT 'Column Order Retained'
		ELSE
			PRINT 'Column Order Compromised'
		PRINT ''
		------------------------------------------------------------------------------------------------
		PRINT '>> Loading Table: crm_sales_details'

		TRUNCATE TABLE Bronze.crm_sales_details
		BULK INSERT Bronze.crm_sales_details
		FROM 'C:\Users\asmaa\Downloads\SQL Course\SQL-Data-Warehouse\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		IF (SELECT COUNT(*) FROM Bronze.crm_sales_details) = 60398
			PRINT 'All Rows  Loaded Successfully'
		ELSE
			PRINT 'Row Loading Integrity Compromised'
		IF (SELECT sls_sales FROM Bronze.crm_sales_details WHERE sls_ord_num = 'SO65686' AND sls_prd_key = 'BC-M005') = 10
			PRINT 'Column Order Retained'
		ELSE
			PRINT 'Column Order Compromised'
		PRINT ''
		------------------------------------------------------------------------------------------------
		PRINT '--------------------------------------------------------------------'
		PRINT '>> Loading ERP Tables'
		PRINT '--------------------------------------------------------------------'
		PRINT '>> Loading Table: erp_cust_az12'

		TRUNCATE TABLE Bronze.erp_cust_az12
		BULK INSERT Bronze.erp_cust_az12
		FROM 'C:\Users\asmaa\Downloads\SQL Course\SQL-Data-Warehouse\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		IF (SELECT COUNT(*) FROM Bronze.erp_cust_az12) = 18484
			PRINT 'All Rows  Loaded Successfully'
		ELSE
			PRINT 'Row Loading Integrity Compromised'
		IF (SELECT bdate FROM Bronze.erp_cust_az12 where cid = 'NASAW00011241') = '4/6/1974'
			PRINT 'Column Order Retained'
		ELSE
			PRINT 'Column Order Compromised'
		PRINT ''
		------------------------------------------------------------------------------------------------
		PRINT '>> Loading Table: erp_loc_a101'

		TRUNCATE TABLE Bronze.erp_loc_a101
		BULK INSERT Bronze.erp_loc_a101
		FROM 'C:\Users\asmaa\Downloads\SQL Course\SQL-Data-Warehouse\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		IF (SELECT COUNT(*) FROM Bronze.erp_loc_a101) = 18484
			PRINT 'All Rows  Loaded Successfully'
		ELSE
			PRINT 'Row Loading Integrity Compromised'
		IF (SELECT cntry FROM Bronze.erp_loc_a101 where cid = 'AW-00029456') = 'Australia'
			PRINT 'Column Order Retained'
		ELSE
			PRINT 'Column Order Compromised'
		PRINT ''
		------------------------------------------------------------------------------------------------
		PRINT '>> Loading Table: erp_px_cat_g1v2'

		TRUNCATE TABLE Bronze.erp_px_cat_g1v2
		BULK INSERT Bronze.erp_px_cat_g1v2
		FROM 'C:\Users\asmaa\Downloads\SQL Course\SQL-Data-Warehouse\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		IF (SELECT COUNT(*) FROM Bronze.erp_px_cat_g1v2) = 37
			PRINT 'All Rows  Loaded Successfully'
		ELSE
			PRINT 'Row Loading Integrity Compromised'
		IF (SELECT subcat FROM Bronze.erp_px_cat_g1v2 where id = 'CL_CA') = 'Caps'
			PRINT 'Column Order Retained'
		ELSE
			PRINT 'Column Order Compromised'
		PRINT ''
	END TRY
	BEGIN CATCH
		PRINT '========================================================================='
		PRINT 'ERROR OCCURED DURING LOADING OF THE BRONZE LAYER'
		PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR)
		PRINT '========================================================================='
	END CATCH
END

EXEC Bronze.load_bronze