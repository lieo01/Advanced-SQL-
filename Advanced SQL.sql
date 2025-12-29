

-- ============================================================
-- PART 1: THEORY QUESTIONS
-- ============================================================

/*
Q1. What is a Common Table Expression (CTE), and how does it improve SQL query readability?
ANSWER:
A CTE is a temporary result set defined using the `WITH` keyword. It exists only during the execution of a single query.
It improves readability by:
1. Breaking complex logic into smaller, named steps.
2. Removing the need for messy nested subqueries.
3. Allowing the same temporary table to be referenced multiple times in one query.

Q2. Why are some views updatable while others are read-only? Explain with an example.
ANSWER:
- Updatable Views: Map directly 1-to-1 with a table row. They have no grouping or calculations.
  (Example: A view selecting just `Name` and `Price` allows you to update the Price).
- Read-Only Views: Contain aggregate functions (SUM, AVG), GROUP BY, or DISTINCT.
  (Example: A view showing "Average Price by Category" cannot be updated because SQL doesn't know which individual product's price to change to adjust the average).

Q3. What advantages do stored procedures offer compared to writing raw SQL queries repeatedly?
ANSWER:
1. Reusability: Write the code once, call it many times with different inputs.
2. Performance: The database parses and compiles the plan once, making execution faster.
3. Security: You can give users permission to run the procedure without giving them access to the raw tables.

Q4. What is the purpose of triggers in a database? Mention one use case where a trigger is essential.
ANSWER:
A trigger is code that automatically executes in response to an event (INSERT, UPDATE, DELETE).
Essential Use Case: Auditing. If a record is deleted, a trigger can automatically save a copy of that data to an Archive table before it vanishes.

Q5. Explain the need for data modelling and normalization when designing a database.
ANSWER:
- Normalization: Organizing data to reduce redundancy (duplicate data). This saves space and prevents inconsistencies (e.g., updating a customer's address in one place updates it everywhere).
- Data Modelling: Creating a visual blueprint of relationships (Primary/Foreign keys) to ensure data accuracy and integrity.
*/

-- ============================================================
-- PART 2: PRACTICAL IMPLEMENTATION (DATABASE SETUP)
-- ============================================================

-- 1. Create Tables
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2)
);

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    ProductID INT,
    Quantity INT,
    SaleDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
);

-- 2. Insert Data
INSERT INTO Products VALUES
(1, 'Keyboard', 'Electronics', 1200),
(2, 'Mouse', 'Electronics', 800),
(3, 'Chair', 'Furniture', 2500),
(4, 'Desk', 'Furniture', 5500);

INSERT INTO Sales VALUES
(1, 1, 4, '2024-01-05'),
(2, 2, 10, '2024-01-06'),
(3, 3, 2, '2024-01-10'),
(4, 4, 1, '2024-01-11');

-- ============================================================
-- PART 3: PRACTICAL SOLUTIONS (Q6 - Q10)
-- ============================================================

-- Q6: Write a CTE to calculate total revenue per product.
-- Return only products where Revenue > 3000.
WITH ProductRevenue AS (
    SELECT 
        p.ProductName, 
        (p.Price * s.Quantity) as TotalRevenue
    FROM Products p
    JOIN Sales s ON p.ProductID = s.ProductID
)
SELECT * FROM ProductRevenue
WHERE TotalRevenue > 3000;


-- Q7: Create a view vw_CategorySummary (Category, TotalProducts, AveragePrice).
CREATE VIEW vw_CategorySummary AS
SELECT 
    Category,
    COUNT(ProductID) as TotalProducts,
    AVG(Price) as AveragePrice
FROM Products
GROUP BY Category;


-- Q8: Create an updatable view and update ProductID = 1.
CREATE VIEW vw_ProductPrice AS
SELECT ProductID, ProductName, Price
FROM Products;

UPDATE vw_ProductPrice
SET Price = 1500
WHERE ProductID = 1;


-- Q9: Create a Stored Procedure to get products by Category.
DELIMITER //

CREATE PROCEDURE GetProductsByCategory(IN myCategory VARCHAR(50))
BEGIN
    SELECT * FROM Products 
    WHERE Category = myCategory;
END //

DELIMITER ;

-- Test the Procedure
CALL GetProductsByCategory('Electronics');


-- Q10: Create an AFTER DELETE trigger to archive deleted products.
-- Step A: Create Archive Table
CREATE TABLE ProductArchive (
    ProductID INT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    DeletedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step B: Create Trigger
DELIMITER //

CREATE TRIGGER trg_AfterProductDelete
AFTER DELETE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO ProductArchive (ProductID, ProductName, Category, Price)
    VALUES (OLD.ProductID, OLD.ProductName, OLD.Category, OLD.Price);
END //

DELIMITER ;

-- Test the Trigger
DELETE FROM Products WHERE ProductID = 1;
SELECT * FROM ProductArchive;