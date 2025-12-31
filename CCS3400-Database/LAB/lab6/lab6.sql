-- Q1
SELECT employee_id AS Id,
       first_name || ' ' || last_name AS Names
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM departments
    WHERE department_name = 'Sales'
);

--Q2
SELECT employee_id,first_name || ' ' || last_name AS "Names", job_id, salary
FROM employees
WHERE job_id <> 'SA_REP'
  AND salary > (
        SELECT MIN(salary)
        FROM employees
        WHERE job_id = 'SA_MAN'
      );

--Q3
SELECT employee_id, first_name || ' ' || last_name AS "Names", salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary ASC;

--Q4
SELECT last_name, job_id
FROM employees
WHERE job_id = (
    SELECT job_id
    FROM employees
    WHERE last_name = 'Grant'
);

--Q5
SELECT last_name, department_id, job_id
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id = 1700
);

--Q6
SELECT last_name, salary
FROM employees
WHERE manager_id = (
    SELECT employee_id
    FROM employees
    WHERE last_name = 'King'
);

--Q7
SELECT department_id,
       last_name,
       job_id
FROM employees
WHERE department_id IN (
        SELECT department_id
        FROM departments
        WHERE department_name = 'Sales'
);

--Q8
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE job_id <> 'IT_PROG'
  AND salary < ALL (
        SELECT salary
        FROM employees
        WHERE job_id = 'IT_PROG'
      );