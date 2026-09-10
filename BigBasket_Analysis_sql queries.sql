CREATE DATABASE bigbasket_analysis;
USE bigbasket_analysis;
-- REMOVE NULL values
SELECT 
    *
FROM
    products
WHERE
    product IS NULL OR category IS NULL
        OR sub_category IS NULL
        OR brand IS NULL
        OR product IS NULL
        OR sale_price IS NULL
        OR market_price IS NULL
        OR type IS NULL
        OR rating IS NULL
        OR description IS NULL;
-- REMOVE DUPLICATES
SELECT 
    product, brand, sale_price, market_price, COUNT(*) AS total
FROM
    products
GROUP BY product , brand , sale_price , market_price
HAVING COUNT(*) > 1;

-- BLANK VALUES
SELECT 
    *
FROM
    products
WHERE
    product = '' OR brand = ''
        OR category = ''
        OR sub_category = ''
        OR sale_price = ''
        OR market_price = ''
        OR type = ''
        OR rating = '';
        
-- EXTRA SPACES
SELECT TRIM(product) FROM produts;

-- INVALID RATINGS 
SELECT 
    *
FROM
    products
WHERE
    rating < 0 OR rating > 5;
    
-- WHAT IS THE TOTAL NUMBER OF PRODUCTS?
SELECT 
    COUNT(*) AS total_products
FROM
    products;

-- HOW MANY CATEGORIES ARE AVAILABLE?
SELECT 
    COUNT(DISTINCT category) AS total_categories
FROM
    products;

-- HOW MANY SUB-CATEGORIES ARE AVAILABLE?
SELECT 
    COUNT(DISTINCT Sub_Category) AS total_sub_categories
FROM
    products;
    
-- HOW MANY UNIQUE BRAND ARE AVAILABLE?
    SELECT 
    COUNT(DISTINCT brand) AS total_brands
FROM
    products;
	
  -- WHICH PRODUCT HAS THE HIGHEST SALE PRICE?
  
  SELECT 
    product, sale_price
FROM
    products
ORDER BY sale_price DESC;

-- WHICH PRODUCT HAS THE LOWEST SALE PRICE?
SELECT 
    product, sale_price
FROM
    products
ORDER BY sale_price ASC;

-- which is the average sale price of all products?
SELECT 
    AVG(sale_price) AS average_sales_price
FROM
    products;
    
-- which is the average market price of all products?
 SELECT 
    AVG(market_price) AS average_market_price
FROM
    products;
    
-- WHICH PRODUCT HAS THE HIGHEST RATING?
SELECT 
    product, rating
FROM
    products
ORDER BY rating DESC LIMIT 1;

-- WHICH CATEGORY HAS THE HIGHEST NUMBER OF PRODUCTS?
SELECT 
    category, COUNT(*) AS total_products
FROM
    products
GROUP BY category
ORDER BY total_products DESC
LIMIT 1;

-- WHICH BRAND HAS THE HIGHEST NUMBER OF PRODUCTS?

SELECT 
   brand, COUNT(*) AS total_brand
FROM
    products
GROUP BY brand
ORDER BY total_brand DESC
LIMIT 1;

-- WHAT IS THE AVERAGE RATING FOR EACH CATEGORY?
SELECT 
    category, AVG(rating) AS average_rating
FROM
    products
GROUP BY category;

-- WHAT IS THE AVERAGE RATING OF EACH BRAND?
SELECT 
    brand, AVG(rating) AS avg_brand
FROM
    products
GROUP BY brand;

-- WHAT IS THE AVERAGE SALE PRICE OF EACH CATEGORY?
SELECT 
    category, AVG(sale_price) AS avg_sale_price
FROM
    products
GROUP BY category;

-- WHICH ARE THE TOP 10 PRODUCTS WITH THE HIGHEST DISCOUNT?
SELECT 
    product,
    market_price,
    sale_price,
    (market_price - sale_price) AS discount
FROM
    products
ORDER BY discount DESC
LIMIT 10;

-- WHICH ARE THE DISCOUNT PERCENTAGE FOR EACH PRODUCTS?
SELECT 
    product,
    market_price,
    sale_price,
    ((market_price - sale_price) / market_price) * 100
FROM
    products;
    
-- WHICH CATEGORY HAS THE HIGHEST AVERAGE DISCOUNT?
SELECT 
    category, AVG(market_price - sale_price) AS average_discount
FROM
    products
GROUP BY category
ORDER BY average_discount DESC;

-- WHICH PRODUCTS HAVE A RATING GREATER THAN OR EQUAL TO 4.5?
SELECT 
    product, rating
FROM
    products
WHERE
    rating >= 4.5;
    
-- FIND THE HIGHEST-RATED PRODUCT IN EACH CATEGORY.
SELECT category, product, rating FROM (SELECT category, product, rating, RANK() OVER (PARTITION BY category ORDER BY rating DESC) AS rnk FROM products) t WHERE rnk = 1;

-- FIND THE MOST EXPENSIVE PRODUCT FOR EACH BRAND.
SELECT 
    brand, product, sale_price
FROM
    products
WHERE
    (brand , sale_price) IN (SELECT 
            brand, MAX(sale_price)
        FROM
            products
        GROUP BY brand);
        
-- FIND THE PRODUCTS WHOSE SALE PRICE IS GREATER THAN AVERAGE SALE PRICE.
SELECT 
    product, sale_price
FROM
    products
WHERE
    sale_price > (SELECT 
            AVG(sale_price)
        FROM
            products);  
  
-- FIND THE PRODUCTS WITH THE LOWEST RATING.
SELECT 
    product, rating
FROM
    products
WHERE
    rating = (SELECT 
            MIN(rating)
        FROM
            products);
            
-- RANK THE PRODUCTS BASED ON DISCOUNT.

SELECT product, market_price, sale_price, (market_price - sale_price) 
AS Discount, RANK() OVER (ORDER BY (market_price - sale_price) DESC ) AS Discount_Rank FROM products;

-- RANK BRANDS BASED ON THEIR AVERAGE RATING.

SELECT brand, AVG(rating) AS Avg_Rating, RANK() OVER (ORDER BY AVG(rating) DESC )
 AS Rating_Rank FROM products GROUP BY brand;

-- CLASSIFY PRODUCTS INTO BUDGET, MID-RANGE, AND PREMIUM BASED ON THEIR SALE PRICE.
SELECT 
    product,
    sale_price,
    CASE
        WHEN sale_price < 100 THEN 'Budget'
        WHEN sale_price BETWEEN 100 AND 300 THEN 'Mid-Range'
        ELSE 'premium'
    END AS Price_Category
FROM
    products;
    
-- CLASSIFY PRODUCTS INTO HIGH RATING, MEDIUM-RATING, AND LOW RATING BASED ON THEIR RATING.
SELECT 
    product,
    rating,
    CASE
        WHEN rating >= 4 THEN 'High Rating'
        WHEN rating >=3 THEN 'Medium Rating'
        ELSE 'Low'
    END AS Rating_Category
FROM
    products;
    
-- TOP 3 DISCOUNTED PRODUCTS IN EACH CATEGORY.
WITH ranked_products AS 
(SELECT Product, Category, sale_price, market_price,
ROUND((market_price - sale_price) / market_price * 100, 2) AS Discount_Percentage,ROW_NUMBER() OVER (
PARTITION BY Category ORDER BY (market_price - sale_price) / market_price DESC) 
AS rn
FROM products
WHERE market_price > 0)
SELECT Category, Product, sale_price, market_price, Discount_Percentage
FROM ranked_products
WHERE rn <= 3
ORDER BY Category, Discount_Percentage DESC;