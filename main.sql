-- Create the employee salary database
CREATE DATABASE employee_salary_db;

-- Connect to the database
\c employee_salary_db

-- Create the main employees table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    department VARCHAR(50) NOT NULL
);

-- Create a salary history log table
CREATE TABLE salary_history (
    log_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    old_salary NUMERIC(10, 2) NOT NULL,
    new_salary NUMERIC(10, 2) NOT NULL,
    change_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    change_reason VARCHAR(200)
);

-- Create a trigger function to log salary changes
CREATE OR REPLACE FUNCTION log_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Only log if the salary actually changed
    IF NEW.salary <> OLD.salary THEN
        INSERT INTO salary_history (employee_id, old_salary, new_salary, change_date)
        VALUES (OLD.id, OLD.salary, NEW.salary, CURRENT_TIMESTAMP);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger that fires when salary is updated
CREATE TRIGGER salary_update_trigger
BEFORE UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_salary_change();

-- Insert some sample data
INSERT INTO employees (name, salary, department) VALUES
('John Smith', 50000.00, 'IT'),
('Sarah Johnson', 65000.00, 'HR'),
('Michael Brown', 72000.00, 'Finance'),
('Emily Davis', 48000.00, 'Marketing'),
('David Wilson', 55000.00, 'IT');

-- Example of updating a salary (will trigger the logging)
UPDATE employees SET salary = 53000.00 WHERE name = 'John Smith';
UPDATE employees SET salary = 75000.00 WHERE name = 'Michael Brown';

-- Query to view the main employee table
SELECT * FROM employees;

-- Query to view the salary history log
SELECT e.name, sh.old_salary, sh.new_salary, sh.change_date
FROM salary_history sh
JOIN employees e ON sh.employee_id = e.id
ORDER BY sh.change_date DESC;
