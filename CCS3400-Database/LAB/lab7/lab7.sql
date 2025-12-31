--Q1
SELECT location_id,
       street_address,
       city,
       state_province,
       country_name AS country
FROM locations
NATURAL JOIN countries;

--Q2
SELECT e.last_name,
       e.department_id,
       d.department_name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id;

--Q3
SELECT e.last_name,
       e.job_id,
       e.department_id,
       d.department_name
FROM employees e
JOIN departments d
ON e.department_id = d.department_id
JOIN locations l
ON d.location_id = l.location_id
WHERE l.city = 'Toronto';

--Q4
SELECT e.last_name AS employee,
       e.employee_id AS emp#,
       m.last_name AS manager,
       m.employee_id AS mgr#
FROM employees e
JOIN employees m
ON e.manager_id = m.employee_id;


--Q5
SELECT e.last_name AS employee,
       e.employee_id AS emp#,
       m.last_name AS manager,
       m.employee_id AS mgr#
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.employee_id
ORDER BY e.employee_id;

--Q6
SELECT e1.last_name AS employee,
       e1.department_id,
       e2.last_name AS colleague
FROM employees e1
JOIN employees e2
ON e1.department_id = e2.department_id
AND e1.employee_id <> e2.employee_id
ORDER BY e1.last_name;

--Q7
DESC job_grades;

SELECT e.last_name,
       e.job_id,
       d.department_name,
       e.salary,
       g.grade_level
FROM employees e
JOIN departments d
ON e.department_id = d.department_id
JOIN job_grades g
ON e.salary BETWEEN g.lowest_sal AND g.highest_sal;

--Q8
SELECT e.last_name,
       e.hire_date
FROM employees e
WHERE e.hire_date >
      (SELECT hire_date
       FROM employees
       WHERE last_name = 'Davies');


--Q9
SELECT e.last_name AS employee,
       e.hire_date AS emp_hire_date,
       m.last_name AS manager,
       m.hire_date AS mgr_hire_date
FROM employees e
JOIN employees m
ON e.manager_id = m.employee_id
WHERE e.hire_date < m.hire_date;

--Q10

    SELECT department_id
    FROM departments
MINUS
    SELECT DISTINCT department_id
    FROM employees
    WHERE job_id = 'ST_CLERK';

--Q11
SELECT e.employee_id,
       e.job_id
FROM employees e
JOIN job_history j
ON e.employee_id = j.employee_id
WHERE e.job_id = j.job_id;