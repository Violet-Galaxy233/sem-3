
-- Q1. Find employee with last name 'Higgins'
SELECT first_name || ' ' || last_name AS full_name,
       department_id,
       salary
FROM employees
WHERE last_name = 'Higgins';


-- Q2. Employees earning more than $10000
SELECT last_name,
       salary
FROM employees
WHERE salary > 10000;


-- Q3. Display last name and department number for employee ID 201
SELECT last_name,
       department_id
FROM employees
WHERE employee_id = 201;


-- Q4. Employees whose salary NOT between 5000 and 12000
SELECT last_name,
       salary
FROM employees
WHERE salary NOT BETWEEN 5000 AND 12000;


-- Q5. Employees Matos and Taylor, ordered by start date
SELECT last_name,
       job_id,
       hire_date
FROM employees
WHERE last_name IN ('Matos', 'Taylor')
ORDER BY hire_date ASC;


-- Q6. Employees in department 20 or 50, sorted alphabetically
SELECT last_name,
       department_id
FROM employees
WHERE department_id IN (20, 50)
ORDER BY last_name ASC;


-- Q7. Employees earning 5000–12000 and in department 20 or 50
SELECT last_name AS "Employee",
       salary AS "Monthly Salary"
FROM employees
WHERE salary BETWEEN 5000 AND 12000
  AND department_id IN (20, 50);


-- Q8. Employees whose salary starts with 170 (i.e., 17000+)
SELECT first_name || ' ' || last_name AS full_name,
       job_id,
       salary
FROM employees
WHERE TO_CHAR(salary) LIKE '170%';


-- Q9. Employees hired in 1994
SELECT last_name,
       hire_date
FROM employees
WHERE TO_CHAR(hire_date, 'YYYY') = '1994';


-- Q10. Employees who do not have a manager
SELECT last_name,
       job_id
FROM employees
WHERE manager_id IS NULL;


-- Q11. Employees earning commission, sorted by salary DESC then commission DESC
SELECT last_name,
       salary,
       commission_pct
FROM employees
WHERE commission_pct IS NOT NULL
ORDER BY salary DESC, commission_pct DESC;


-- Q12. Last names where the 3rd letter is 'a'
SELECT last_name
FROM employees
WHERE last_name LIKE '__a%';


-- Q13. Last names containing both 'a' and 'e'
SELECT last_name
FROM employees
WHERE last_name LIKE '%a%'
  AND last_name LIKE '%e%';


-- Q14. Job = 'Sales Representative' OR 'Stock Clerk'
--      but salary NOT 2500, 3500, or 7000
SELECT last_name,
       job_id AS job,
       salary
FROM employees
WHERE job_id IN ('SA_REP', 'ST_CLERK')
  AND salary NOT IN (2500, 3500, 7000);


-- Q15. Clerks hired after 1997
SELECT first_name || ' ' || last_name AS full_name,
       job_id,
       hire_date
FROM employees
WHERE job_id LIKE '%CLERK%'
  AND hire_date > TO_DATE('31-DEC-1997', 'DD-MON-YYYY');


-- Q16. Employees whose last name has no letter 'A'
SELECT first_name || ' ' || last_name AS full_name
FROM employees
WHERE UPPER(last_name) NOT LIKE '%A%';


-- Q17. Employees who earn commission (again, HR report)
SELECT last_name,
       job_id AS job,
       salary,
       commission_pct
FROM employees
WHERE commission_pct IS NOT NULL
ORDER BY salary DESC;


-- Q18. Employees whose commission amount = 20%
SELECT last_name,
       salary,
       commission_pct
FROM employees
WHERE commission_pct = 0.2;
