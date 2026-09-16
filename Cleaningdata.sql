--CREATING A STAGING TABLE
DROP TABLE IF EXISts online_retail_staging;

-- Creates the staging table AND copies all data in one command
CREATE TABLE online_retail_staging AS 
SELECT * FROM online_retail_trans;

SELECT *
FROM online_retail_staging;

--CLEANING DATA
--STEP 1 REMOVE DUPLICATES
WITH cte1 AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY invoice, stockcode, description, 
quantity, invoicedate, price, customer, country) AS duplication1
FROM online_retail_staging)
SELECT *
FROM cte1
WHERE duplication1>1;

--VERIFICATION OF DUPLICATES
SELECT *
FROM online_retail_staging
Where description ='VINTAGE SNAKES & LADDERS';

--REMOVING DUPLIACTES
ALTER TABLE online_retail_staging
ADD COLUMN row_id SERIAL PRIMARY KEY;

SELECT *
FROM online_retail_staging;

WITH duplication AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY invoice, stockcode, description, 
quantity, invoicedate, price, customer, country) AS duplication1
FROM online_retail_staging)
DELETE 
FROM online_retail_staging
WHERE row_id IN (
    SELECT row_id
    FROM duplication
    WHERE duplication1 > 1
);

----Checking duplicate once again
WITH duplicate_check AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY invoice, stockcode, description, 
quantity, invoicedate, price, customer, country) AS duplication1
FROM online_retail_staging)
SELECT *
FROM duplicate_check
WHERE duplication1>1;

--standardizing data
SELECT DISTINCT(stockcode), LENGTH(stockcode) 
FROM online_retail_staging;

UPDATE online_retail_staging
SET country=TRIM(country);

SELECT *
FROM online_retail_staging;

--looking at nulls or blank values
SELECT *
FROM online_retail_staging
where description is null or description='';

--treating the blank values
ALTER TABLE online_retail_staging
ALTER COLUMN price TYPE NUMERIC(10,2)
USING price::NUMERIC;

DELETE
FROM online_retail_staging
WHERE description IS NULL 
	AND customer IS NULL 
	AND price=0;

SELECT *
FROM online_retail_staging
where customer is null or customer='';

DELETE
FROM online_retail_staging
WHERE customer IS NULL 
	AND price=0;

UPDATE online_retail_staging
SET customer='Guest'
WHERE customer IS NULL;

SELECT *
FROM online_retail_staging;

--DEALING WITH NEGATIVE QUANTITES
SELECT *
FROM online_retail_staging
WHERE Quantity<'0';

ALTER TABLE online_retail_staging
ADD COLUMN transaction_type VARCHAR(50);

UPDATE online_retail_staging
SET  transaction_type=
	CASE
	WHEN QUANTITY<'0' THEN 'RETURN'
	ELSE 'SALE'
	END ;

SELECT *
FROM online_retail_staging;

--standardizing the customer_id from .0 to 0
UPDATE online_retail_staging
SET customer=REPLACE(customer,'.0','')
WHERE customer LIKE '%.0';

SELECT *
FROM online_retail_staging;

--STANDARDIZING INVOICEDATE
SELECT DISTINCT(invoicedate)
FROM online_retail_staging;
--Standardizing column data types
ALTER TABLE online_retail_staging
ALTER COLUMN invoice TYPE VARCHAR(20)
USING invoice::VARCHAR(20);

ALTER TABLE online_retail_staging
ALTER COLUMN stockcode TYPE VARCHAR(20)
USING stockcode::VARCHAR(20);

ALTER TABLE online_retail_staging
ALTER COLUMN invoicedate TYPE TIMESTAMP
USING invoicedate::TIMESTAMP;

ALTER TABLE online_retail_staging
ALTER COLUMN quantity TYPE NUMERIC(10,0)
USING quantity::NUMERIC(10,0);

ALTER TABLE online_retail_staging
RENAME COLUMN customer TO customer_id;

ALTER TABLE online_retail_staging
ALTER COLUMN customer_id TYPE VARCHAR(20)
USING customer_id::VARCHAR(20);

ALTER TABLE online_retail_staging
ALTER COLUMN country TYPE VARCHAR(20)
USING country::VARCHAR(20);