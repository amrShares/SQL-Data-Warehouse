/*
=================================================
 Data Exploration of the Bronze Layer Tables
=================================================
*/

--> Data Exploration of the CRM Source Tables
 
 --------------------------------------------------
 -- Exploring cust_info
 --------------------------------------------------

 -- A wholistic view on the table
 SELECT * FROM Bronze.crm_cust_info

 -- Exploring uniqueness cst_id
SELECT
cst_id,
COUNT(*)
FROM Bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) != 1

-- detecting nulls in cst_id
SELECT
*
FROM Bronze.crm_cust_info
WHERE cst_id IS NULL

-- detecting duplicates in cst_id
SELECT
cst_id,
COUNT(*)
FROM Bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) != 1

-- detecting unwanted spaces in cst_first_name, cst_lastname
SELECT
cst_firstname,
TRIM(cst_firstname)
FROM Bronze.crm_cust_info
WHERE TRIM(cst_firstname) != cst_firstname

SELECT
cst_lastname,
TRIM(cst_lastname)
FROM Bronze.crm_cust_info
WHERE TRIM(cst_lastname) != cst_lastname

-- ensuring consistent values in cst_gndr
SELECT DISTINCT(cst_gndr) FROM Bronze.crm_cust_info

 --------------------------------------------------
 -- Exploring prd_info
 --------------------------------------------------

 -- A wholistic view on the table
SELECT * FROM Bronze.crm_prd_info

 -- Exploring uniqueness prd_id
SELECT
prd_id,
COUNT(*)
FROM Bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) != 1

-- detecting nulls in prd_id
SELECT
*
FROM Bronze.crm_prd_info
WHERE prd_id IS NULL

-- detecting duplicates in prd_id
SELECT
prd_id,
COUNT(*)
FROM Bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) != 1

-- detecting unwanted spaces in prd_nm, prd_key
SELECT
prd_nm,
TRIM(prd_nm)
FROM Bronze.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm

SELECT
prd_key,
TRIM(prd_key)
FROM Bronze.crm_prd_info
WHERE TRIM(prd_key) != prd_key

-- chcking for nulls or negatives in product prices, we choose to retiain nulls but 
SELECT
*
FROM Bronze.crm_prd_info
Where prd_cost IS NULL OR prd_cost < 0

-- check consistency of values within prd_line
SELECT DISTINCT(prd_line) FROM Bronze.crm_prd_info

-- ensuring produccts end dates are later than their start dates
SELECT 
*
FROM Bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt

-- Understanding whether product keys are unique
SELECT
prd_key,
COUNT(*)
FROM Bronze.crm_prd_info
GROUP BY prd_key
HAVING COUNT(*) > 1


 --------------------------------------------------
 -- Exploring sales_details
 --------------------------------------------------
  -- A wholistic view on the table
 SELECT * FROM Bronze.crm_sales_details

 -- Ensuring uniqueness of sls_ord_num coupled with sls_prd_key we understand that each orderd number takes a number of records depending on the number of items in the order
SELECT
sls_ord_num,
COUNT(*)
FROM Bronze.crm_sales_details
GROUP BY sls_ord_num, sls_prd_key
HAVING COUNT(*) != 1

-- checking for invalid sales dates
SELECT
sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt <= 0

-- checking for inconsistency between order and shipping
SELECT
*
FROM Bronze.crm_sales_details
WHERE sls_ship_dt < sls_order_dt

-- ensuring sales reflect quantites and prices
SELECT
	sls_sales,
	sls_quantity,
	sls_price
FROM Bronze.crm_sales_details
WHERE
	sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL
	OR sls_price IS NULL
	OR sls_quantity IS NULL
	OR sls_sales <=0
	OR sls_price <=0
	OR sls_quantity <=0 

--> Data Exploration of the ERP Source Tables

--------------------------------------------------
-- Exploring erp_cust_az12
--------------------------------------------------
 -- A wholistic view on the table
SELECT * FROM Bronze.erp_cust_az12

--------------------------------------------------
-- Exploring erp_loc_a101
--------------------------------------------------
 -- A wholistic view on the table
SELECT * FROM Bronze.erp_loc_a101

-- checking the uniqueness of customer ids

SELECT
cid,
COUNT(*)
FROM Bronze.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) != 1

-- checking the nullability of customer ids
SELECT * FROM Bronze.erp_loc_a101 where cid IS NULL

-- checking the cardinality of the customer countries 'cntry'

SELECT DISTINCT cntry FROM Bronze.erp_loc_a101

--------------------------------------------------
-- Exploring erp_px_cat_g1v2
--------------------------------------------------
 -- A wholistic view on the table
SELECT * FROM Bronze.erp_px_cat_g1v2

-- checking nullability of id
SELECT id from Bronze.erp_px_cat_g1v2 WHERE id IS NULL

-- checking for unwanted spaces
SELECT
*
FROM Bronze.erp_px_cat_g1v2
WHERE
	TRIM(cat) != cat OR
	TRIM(subcat) != subcat OR
	TRIM(maintenance) != maintenance

-- checking the consistency of the maintenance column
SELECT DISTINCT maintenance FROM Bronze.erp_px_cat_g1v2