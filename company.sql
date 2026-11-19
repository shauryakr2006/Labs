DROP DATABASE IF EXISTS company;
CREATE DATABASE company;
USE company;

-- 1. Create Tables
CREATE TABLE employee (
    ssn VARCHAR(35) PRIMARY KEY,
    name VARCHAR(35) NOT NULL,
    address VARCHAR(250) NOT NULL,
    sex VARCHAR(7) NOT NULL,
    salary INT NOT NULL,
    super_ssn VARCHAR(35),
    dno INT,
    FOREIGN KEY (super_ssn) REFERENCES employee(ssn) 
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE department (
    dno INT PRIMARY KEY,
    dname VARCHAR(100) NOT NULL,
    mgr_ssn VARCHAR(35),
    mgr_startdate DATE,
    FOREIGN KEY (mgr_ssn) REFERENCES employee(ssn) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE dlocation (
    dno INT NOT NULL,
    dloc VARCHAR(100) NOT NULL,
    PRIMARY KEY (dno, dloc),
    FOREIGN KEY (dno) REFERENCES department(dno) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE project (
    pno INT PRIMARY KEY,
    pname VARCHAR(35) NOT NULL,
    ploc VARCHAR(35) NOT NULL,
    dno INT NOT NULL,
    FOREIGN KEY (dno) REFERENCES department(dno) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE works_on (
    ssn VARCHAR(35) NOT NULL,
    pno INT NOT NULL,
    hours INT NOT NULL DEFAULT 0,
    PRIMARY KEY (ssn, pno),
    FOREIGN KEY (ssn) REFERENCES employee(ssn) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (pno) REFERENCES project(pno) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 2. Insert Sample Data (Insert employees before adding dno FK to avoid circular dependency)
INSERT INTO employee VALUES
('01NB235', 'Chandan Krishna', 'Siddartha Nagar, Mysuru', 'Male', 150000, '01NB235', 5),
('01NB354', 'Arun', 'Vijayanagar, Mysuru', 'Male', 200000, '01NB235', 2),
('02NB254', 'Lakshmi', 'Pune, Maharashtra', 'Female', 100000, '01NB235', 4),
('03NB653', 'Arjun', 'Hyderabad, Telangana', 'Male', 250000, '01NB354', 5),
('04NB234', 'Disha', 'JP Nagar, Bengaluru', 'Female', 170000, '01NB354', 1);

INSERT INTO department VALUES
(1, 'Human Resources', '01NB235', '2020-10-21'),
(2, 'Quality Assessment', '03NB653', '2020-10-19'),
(3, 'System Assessment', '04NB234', '2020-10-27'),
(4, 'Accounts', '01NB354', '2020-09-04'),
(5, 'Production', '02NB254', '2020-08-16');

-- Add circular foreign key after both tables are populated
ALTER TABLE employee 
ADD FOREIGN KEY (dno) REFERENCES department(dno) 
ON DELETE SET NULL ON UPDATE CASCADE;

INSERT INTO dlocation VALUES
(1, 'Jayanagar, Bengaluru'),
(2, 'Vijayanagar, Mysuru'),
(3, 'Chennai, Tamil Nadu'),
(4, 'Mumbai, Maharashtra'),
(5, 'Kuvempunagar, Mysuru');

INSERT INTO project VALUES
(241563, 'System Testing', 'Mumbai, Maharashtra', 4),
(532678, 'IOT', 'JP Nagar, Bengaluru', 1),
(453723, 'Production Optimisation', 'Hyderabad, Telangana', 5),
(278345, 'Yield Increase', 'Kuvempunagar, Mysuru', 5),
(426784, 'Product Refinement', 'Saraswathipuram, Mysuru', 2);

INSERT INTO works_on VALUES
('01NB235', 278345, 5),
('01NB354', 426784, 6),
('04NB234', 532678, 3),
('02NB254', 241563, 3),
('03NB653', 453723, 6);

-- 3. Queries

-- Q1: List project numbers involving an employee whose last name is 'Krishna' 
-- either as a worker or as a manager of the controlling department
SELECT DISTINCT p.pno, p.pname
FROM project p
JOIN works_on w ON p.pno = w.pno
JOIN employee e ON w.ssn = e.ssn
WHERE e.name LIKE '%Krishna'
UNION
SELECT DISTINCT p.pno, p.pname
FROM project p
JOIN department d ON p.dno = d.dno
JOIN employee e ON d.mgr_ssn = e.ssn
WHERE e.name LIKE '%Krishna';

-- Q2: Show resulting salaries of every employee working on the 'IOT' project given a 10% raise
SELECT w.ssn, e.name, e.salary AS old_salary, (e.salary * 1.10) AS new_salary
FROM works_on w
JOIN employee e ON w.ssn = e.ssn
WHERE w.pno = (
    SELECT pno FROM project WHERE pname = 'IOT'
);

-- Q3: Find sum, max, min, and average salary of all employees in the 'Accounts' department
SELECT SUM(e.salary) AS sal_sum, 
       MAX(e.salary) AS sal_max, 
       MIN(e.salary) AS sal_min, 
       AVG(e.salary) AS sal_avg
FROM employee e
JOIN department d ON e.dno = d.dno
WHERE d.dname = 'Accounts';

-- Q4: Retrieve the name of each employee who works on all projects controlled by department 1
SELECT e.ssn, e.name, e.dno
FROM employee e
WHERE NOT EXISTS (
    SELECT p.