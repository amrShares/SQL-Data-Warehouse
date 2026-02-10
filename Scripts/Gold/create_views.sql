
-- Creation of the dim_customers view joining the tables: Silver.crm_cust_info, Silver.erp_cust_az12, and Silver.erp_loc_a101
CREATE OR ALTER VIEW Gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY cn.cst_create_date ASC) AS customer_number, -- practicing the creation of a simple surrogate key
	cn.cst_key AS customer_key,
	cn.cst_id AS customer_id,
	cn.cst_firstname AS first_name,
	cn.cst_lastname AS last_name,
	cb.bdate AS birth_date,
	CASE
		WHEN cb.gen IS NULL OR cb.gen = 'n/a' THEN cn.cst_gndr
		ELSE cb.gen
	END AS gender,
	cn.cst_martial_status AS martial_status,
	cl.cntry AS country,
	cn.cst_create_date AS account_creation_date
FROM Silver.crm_cust_info cn
LEFT JOIN Silver.erp_cust_az12 cb
ON cn.cst_key = cb.cid
LEFT JOIN Silver.erp_loc_a101 cl
ON cn.cst_key = cl.cid
GO

-- Creation of the dim_products view joining the tables: Silver.prod_info and Silver.erp_px_cat_g1v2
CREATE VIEW Gold.dim_products AS
SELECT
	ROW_NUMBER() OVER(ORDER BY cpr.prd_start_dt ASC, cpr.prd_key ASC) product_number,
	cpr.prd_id product_id,
	cpr.prd_key product_key,
	cpr.prd_nm product_name,
	cpr.cat_id category_id,
	epc.cat category,
	epc.subcat subcategory,
	cpr.prd_line product_line,
	epc.maintenance,
	cpr.prd_cost product_cost,
	cpr.prd_start_dt product_start_date
FROM Silver.crm_prd_info cpr
LEFT JOIN Silver.erp_px_cat_g1v2 epc
ON cpr.cat_id = epc.id
WHERE cpr.prd_end_dt IS NULL
GO


-- Creation of the fact_sales view based on the Silver.crm_sales_details table and the dimensions: dim_customers and dim_products
CREATE OR ALTER VIEW Gold.fact_sales AS
SELECT
sd.sls_ord_num order_number,
sd.sls_prd_key product_key,
dp.product_name,
sd.sls_cust_id customer_id,
TRIM(ISNULL(dc.first_name, '') + ' ' + ISNULL(dc.last_name, '')) AS customer_name,
sd.sls_order_dt order_date,
sd.sls_ship_dt shipping_date,
sd.sls_due_dt due_date,
sd.sls_sales sales,
sd.sls_quantity quantity,
sd.sls_price price
FROM Silver.crm_sales_details sd
LEFT JOIN Gold.dim_products dp
ON sd.sls_prd_key = dp.product_key
LEFT JOIN Gold.dim_customers dc
ON sd.sls_cust_id = dc.customer_id