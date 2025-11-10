-- Q1
SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    LENGTH(last_name) AS last_name_length,
    INSTR(last_name, 'a') AS position_of_a
FROM employees
WHERE last_name LIKE '%n';

--Q2
SELECT SYSDATE AS "Date"
FROM dual;

--Q3
SELECT 
    last_name,
    ROUND((SYSDATE - hire_date) / 7) AS weeks_employed
FROM employees
WHERE department_id = 60;

--Q4
SELECT 
    employee_id,
    last_name,
    salary,
    ROUND(salary * 1.155) AS "New Salary"
FROM employees;

--Q5
SELECT 
    employee_id,
    last_name,
    salary,
    ROUND(salary * 1.155) AS "New Salary",
    ROUND(salary * 1.155) - salary AS "Increase"
FROM employees;

--Q6
SELECT 
    INITCAP(last_name) AS "Formatted Last Name",
    LENGTH(last_name) AS "Length of Last Name"
FROM employees
WHERE last_name LIKE 'J%' 
   OR last_name LIKE 'A%' 
   OR last_name LIKE 'M%'
ORDER BY last_name;
 
 --Q7
 SELECT 
    last_name,
    CEIL(MONTHS_BETWEEN(SYSDATE, hire_date)) AS MONTHS_WORKED
FROM employees
ORDER BY MONTHS_WORKED;

--Q8
SELECT 
    last_name,
    LPAD(TO_CHAR(salary), 15, '$') AS SALARY
FROM employees;

--Q9
SELECT 
    last_name,
    NVL(commission_pct, 0) AS COMM
FROM employees;


--Q10
SELECT 
    SUBSTR(last_name, 1, 8) || ' ' || RPAD('*', ROUND(salary/1000), '*') 
    AS EMPLOYEES_AND_THEIR_SALARIES
FROM employees
ORDER BY salary DESC;

--Q11
SELECT 
    last_name,
    job_id,
    DECODE(job_id,
        'AD_PRES', 'A',
        'ST_MAN',  'B',
        'IT_PROG', 'C',
        'SA_REP',  'D',
        'ST_CLERK','E',
        '0') AS GRADE
FROM employees;

--Q12
SELECT 
    last_name,
    job_id,
    CASE 
        WHEN job_id = 'AD_PRES' THEN 'A'
        WHEN job_id = 'ST_MAN'  THEN 'B'
        WHEN job_id = 'IT_PROG' THEN 'C'
        WHEN job_id = 'SA_REP'  THEN 'D'
        WHEN job_id = 'ST_CLERK' THEN 'E'
        ELSE '0'
    END AS GRADE
FROM employees;