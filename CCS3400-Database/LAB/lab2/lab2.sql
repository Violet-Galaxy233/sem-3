SELECT employee_id,
       last_name,
       salary * 12 AS annual_salary
FROM employees;

CREATE TABLE customers (
    id       NUMBER       CONSTRAINT customers_pk PRIMARY KEY,
    name     VARCHAR2(50) NOT NULL,
    age      NUMBER       NOT NULL,
    address  CHAR(20),
    salary   NUMBER(8,2)
);
DESCRIBE customers

INSERT INTO customers VALUES (1, 'Ramesh', 32, 'Ahmedabad', 2000.00);
INSERT INTO customers VALUES (2, 'Khilan', 25, 'Delhi', 1500.00);
INSERT INTO customers VALUES (3, 'Kaushik', 23, 'Kota', 2000.00);

SELECT * FROM customers;

UPDATE customers
SET address = 'Pune'
WHERE id = 3;

DELETE FROM customers
WHERE id = 2;
SELECT * FROM customers;

ALTER TABLE customers
ADD phone_number VARCHAR2(15);
DESCRIBE customers

DROP TABLE customers;

DESC departments;

SELECT * FROM departments;

DESC employees;

SELECT employee_id,
       last_name,
       job_id,
       hire_date AS startdate
FROM employees;

SELECT DISTINCT job_id
FROM employees;

SELECT last_name,
       salary,
       (salary * 12) + 300 AS annual_compensation
FROM employees;

SELECT employee_id AS "Emp#",
       last_name AS "Employee",
       job_id AS "Job",
       hire_date AS "Hire Date"
FROM employees;
SELECT last_name || ', ' || job_id AS "Employee and Title"
FROM employees;

SELECT employee_id || ', '
       || first_name || ', '
       || last_name || ', '
       || email || ', '
       || phone_number || ', '
       || hire_date || ', '
       || job_id || ', '
       || salary || ', '
       || commission_pct || ', '
       || manager_id || ', '
       || department_id AS "THE_OUTPUT"
FROM employees;

