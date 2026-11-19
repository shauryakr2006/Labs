DROP DATABASE IF EXISTS order_processing;
CREATE DATABASE order_processing;
USE order_processing;

-- 1. Create Tables
CREATE TABLE customers (
    cust_id INT PRIMARY KEY,
    cname VARCHAR(30) NOT NULL,
    city VARCHAR(30) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    odate DATE NOT NULL,
    cust_id INT NOT NULL,
    order_amt INT NOT NULL,
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE items (
    item_id INT PRIMARY KEY,
    unit_price INT NOT NULL
);

CREATE TABLE order_items (
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    qty INT NOT NULL,
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (item_id) REFERENCES items(item_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE warehouses (
    warehouse_id INT PRIMARY KEY,
    city VARCHAR(30) NOT NULL
);

CREATE TABLE shipments (
    order_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    ship_date DATE NOT NULL,
    PRIMARY KEY (order_id, warehouse_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 2. Insert Sample Data
INSERT INTO customers VALUES
(1, 'Ravi', 'Mysuru'),
(2, 'Ram', 'Bengaluru'),
(3, 'Kumar', 'Mumbai'),
(4, 'Kiran', 'Delhi'),
(5, 'Chethan', 'Bengaluru');

INSERT INTO orders VALUES
(1001, '2020-01-14', 1, 2000),
(1002, '2021-01-16', 2, 600),
(1003, '2023-02-15', 3, 2500),
(1004, '2019-09-13', 4, 1000),
(1005, '2020-12-13', 5, 200);

INSERT INTO items VALUES
(1, 400),
(2, 200),
(3, 1000),
(4, 200),
(5, 500);

INSERT INTO warehouses VALUES
(1, 'Mysuru'),
(2, 'Bengaluru'),
(3, 'Mumbai'),
(4, 'Delhi'),
(5, 'Chennai');

INSERT INTO order_items VALUES
(1001, 1, 5),
(1002, 2, 4),
(1003, 3, 1),
(1004, 4, 3),
(1005, 5, 4);

INSERT INTO shipments VALUES
(1001, 1, '2020-01-16'),
(1002, 2, '2021-04-14'),
(1003, 3, '2023-02-18'),
(1004, 4, '2019-09-15'),
(1005, 5, '2020-12-15');

-- 3. Queries

-- Q1: List the order_id and ship_date for all orders shipped from warehouse 1
SELECT order_id, ship_date 
FROM shipments
WHERE warehouse_id = 1;

-- Q2: List the warehouse information from which Customer "Kumar" was supplied his orders
SELECT order_id, warehouse_id, city 
FROM warehouses NATURAL JOIN shipments 
WHERE order_id IN (
    SELECT order_id FROM orders 
    WHERE cust_id IN (
        SELECT cust_id FROM customers WHERE cname LIKE '%Kumar%'
    )
);

-- Q3: Produce a listing: Cname, No_of_orders, Avg_order_amt
SELECT c.cname, COUNT(o.order_id) AS no_of_orders, AVG(o.order_amt) AS avg_order_amt 
FROM customers c
JOIN orders o ON c.cust_id = o.cust_id 
GROUP BY c.cust_id, c.cname;

-- Q4: Delete all orders for customer named "Kumar"
DELETE FROM orders 
WHERE cust_id IN (
    SELECT cust_id FROM customers WHERE cname LIKE '%Kumar%'
);

-- Q5: Find the item with maximum unit price
SELECT * 
FROM items 
WHERE unit_price = (SELECT MAX(unit_price) FROM items);

-- Q6: Create a view to display order_id and shipment date of all orders shipped from warehouse 5
CREATE OR REPLACE VIEW shipment_dates_w5 AS 
SELECT order_id, ship_date 
FROM shipments 
WHERE warehouse_id = 5;

SELECT * FROM shipment_dates_w5;