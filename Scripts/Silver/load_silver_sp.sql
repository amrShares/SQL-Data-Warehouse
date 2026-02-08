CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT 'Truncating table: crm_cust_info'
		TRUNCATE TABLE Silver.crm_cust_info

		-- Data Transformation, Cleaning and Loading of crm_cust_info into the silver layer
		PRINT 'Inserting data into table: crm_cust_info'
		INSERT INTO Silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_martial_status, cst_gndr, cst_create_date)
		SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE UPPER(cst_martial_status)
			WHEN 'M' THEN 'Married'
			WHEN 'S' THEN 'Single'
			ELSE 'n/a'
		END AS cst_martial_status,
		CASE UPPER(cst_gndr)
			WHEN 'F' THEN 'Female'
			WHEN 'M' THEN 'Male'
			ELSE 'n/a'
		END AS cst_gndr,
		cst_create_date
		FROM (
		SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
		FROM Bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
		)t WHERE flag_last = 1 AND cst_id IS NOT NULL


		PRINT 'Truncating table: crm_prd_info'
		TRUNCATE TABLE Silver.crm_prd_info

		PRINT 'Inserting data into table: crm_prd_info'
		-- Data Transformation, Cleaning and Loading of crm_prd_info into the silver layer
		INSERT INTO Silver.crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
		SELECT
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key ,
		prd_nm,
		prd_cost,
		CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line,
		CAST(prd_start_dt AS DATE),
		CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE) AS prd_end_dt
		FROM Bronze.crm_prd_info


		PRINT 'Truncating table: crm_sales_details'
		TRUNCATE TABLE Silver.crm_sales_details

		PRINT 'Inserting data into table: crm_sales_details'
		-- Data Transformation, Cleaning and Loading of crm_sales_details into the silver layer
		INSERT INTO Silver.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
		SELECT
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE 
			WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt
		,
		CASE 
			WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE 
			WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE 
			WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,
		sls_quantity,
		CASE
			WHEN sls_price IS NULL OR sls_price <= 0 THEN NULLIF(ABS(sls_sales), 0) / NULLIF(sls_quantity, 0)
			ELSE sls_price
		END AS sls_price
		FROM Bronze.crm_sales_details


		PRINT 'Truncating table: erp_cust_az12'
		TRUNCATE TABLE Silver.erp_cust_az12

		PRINT 'Inserting data into table: erp_cust_az12'
		-- Data Transformation, Cleaning and Loading of erp_cust_az12 into the silver layer
		INSERT INTO Silver.erp_cust_az12(cid, bdate, gen)
		SELECT
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
			END AS cid,
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE 
				WHEN UPPER(TRIM(gen)) IN ('MALE', 'M') THEN 'Male'
				WHEN UPPER(TRIM(gen)) IN ('FEMALE', 'F') THEN 'Female'
				ELSE 'n/a'
			END AS gen
		FROM Bronze.erp_cust_az12


		PRINT 'Truncating table: erp_loc_a101'
		TRUNCATE TABLE Silver.erp_loc_a101

		PRINT 'Inserting data into table: erp_loc_a101'
		-- Data Transformation, Cleaning and Loading of erp_loc_a101 into the silver layer
		INSERT INTO Silver.erp_loc_a101 (cid, cntry)
		SELECT
		REPLACE(cid, '-', '') AS cid,
		CASE
			WHEN TRIM(UPPER(cntry)) IN ('USA', 'UNITED STATES', 'US') THEN 'United States'
			WHEN TRIM(UPPER(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
			WHEN TRIM(UPPER(cntry)) = '' or cntry IS NULL THEN 'n/a'
			ELSE TRIM(cntry)
		END AS ctnry
		FROM Bronze.erp_loc_a101

		PRINT 'Truncating table: erp_gx_cat_g1v2'
		TRUNCATE TABLE Silver.erp_px_cat_g1v2

		PRINT 'Inserting data into table: erp_px_cat_g1v2'
		-- Data Transformation, Cleaning and Loading of erp_gx_cat_g1v2 into the silver layer
		INSERT INTO Silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
		SELECT
		id,
		cat,
		subcat,
		maintenance
		FROM Bronze.erp_px_cat_g1v2

		SET @batch_end_time = GETDATE()

		PRINT '========================================================================='
		PRINT '>> Load duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
		PRINT '========================================================================='
	END TRY
	BEGIN CATCH
		PRINT '========================================================================='
		PRINT 'ERROR OCCURED DURING LOADING OF THE SILVER LAYER'
		PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR)
		PRINT '========================================================================='
	END CATCH
END