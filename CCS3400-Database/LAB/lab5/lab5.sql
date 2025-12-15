SELECT COUNT(DISTINCT department_name) 
AS number_of_departments
FROM departments;

--Q2
SELECT department_id AS "Department ID",
       SUM(salary) AS "Total Salary Paid"
FROM employees
GROUP BY department_id
ORDER BY department_id;


--Q3
SELECT 
    ROUND(MAX(salary)) AS Maximum,
    ROUND(MIN(salary)) AS Minimum,
    ROUND(SUM(salary)) AS Sum,
    ROUND(AVG(salary)) AS Average
FROM employees;

--Q4
SELECT 
    job_id,
    MIN(salary) AS Minimum,
    MAX(salary) AS Maximum,
    SUM(salary) AS Sum,
    ROUND(AVG(salary)) AS Average
FROM employees
GROUP BY job_id;

--Q5
SELECT 
    job_id,
    COUNT(*) AS number_of_people
FROM employees
GROUP BY job_id;

--Q6
SELECT 
    COUNT(DISTINCT manager_id) AS "Number of Managers"
FROM employees;

--Q7
SELECT 
    MAX(salary) - MIN(salary) AS DIFFERENCE
FROM employees;


--Q8
SELECT 
    department_id,
    SUM(salary) AS total_salary
FROM employees
GROUP BY department_id
HAVING SUM(salary) > 25000;

--Q9
SELECT 
    department_id,
    AVG(salary) AS "Average Salaries"
FROM employees
WHERE department_id IN (50, 60)
GROUP BY department_id;

--Q10
SELECT 
    manager_id,
    MIN(salary) AS lowest_salary
FROM employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id
HAVING MIN(salary) > 6000
ORDER BY lowest_salary DESC;