-- Exploring the tables belonging to dim_customers to decide on the properties to include and joining keys 
SELECT * FROM Silver.crm_cust_info;
SELECT * FROM Silver.erp_cust_az12;
SELECT * FROM silver.erp_loc_a101;

-- checking for differences between the customer gender recorded in Silver.cust_info and Silver.erp_cust_az12,
--  with Silver.cust_info as the master table in case of a conflict
SELECT DISTINCT
cb.gen,
cn.cst_gndr,
CASE
	WHEN cb.gen IS NULL OR cb.gen = 'n/a' THEN cn.cst_gndr
	ELSE cb.gen
END AS patched_gender
FROM Silver.crm_cust_info cn
LEFT JOIN Silver.erp_cust_az12 cb
ON cn.cst_key = cb.cid

-- Exploring the tables belonging to dim_products to decide on the properties to include and joining keys 
SELECT * FROM Silver.crm_prd_info;
SELECT * FROM Silver.erp_px_cat_g1v2;

-- Exploring the sales table
SELECT * FROM Silver.crm_sales_details
