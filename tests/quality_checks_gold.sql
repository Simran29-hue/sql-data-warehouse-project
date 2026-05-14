/* 
=======================================================
QUALITY CHECKS
=======================================================
SCRIPT PURPOSE:
      THIS SCRIPT PERFORMS QUALITY CHECKS TO VALIDATE THE INTEGRITY, CONSISTENCY,
       AND ACCURACY OF THE GOLD LAYERS. THESE CHECKS ENSURES :
       - UNIQUENESS OF SURROGATE KEYS IN DIMENSION TABLES.
       - REFERENTIAL INTEGRITY BETWEEN FACT AND DIMENSION TABLES.
       - VALIDATION OF RELATIONSHIPS IN THE DATA MODEL FOR ANALYTICAL PURPOSE.

USAGE NOTES:
      - RUN THESE CHECKS AFTER DATA LOADING SILVER LAYER.
      - INVESTIGATE AND RESOLVE ANY DISCREPANCIES FOUND DURING THE CHECKS.
======================================================
*/



select distinct
ci.cst_gndr,
ca.gen,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr -- crm is the master for gender info
ELSE coalesce (ca.gen, 'n/a')
END AS new_gen
FROM silver1.crm_cust_info ci
left join silver1.erp_cust_az12 ca
on ci.cst_key = ca.cid
left join silver1.erp_loc_a101 la
on ci.cst_key = la.cid
--================================================
-- CHECKING 'gold.product_key'
--================================================
  -- checking for uniqueness of product key in gold.dim_product
  --expectation: No results
SELECT
  product_key,
  count(*) as duplicate_count
FROM gold.dim_product
GROUP BY product_key
HAVING COUNT(*) > 1;

SELECT
  customer_key,
  count(*) as duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

--================================================
-- foreign key integrity (dimension)
--================================================
select * from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
left join gold.dim_product p
on p.product_key = f.product_key
where p.product_key is null or c.customer_key IS NULL
