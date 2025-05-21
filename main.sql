-- Main employee table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL
);
-- Salary history log table
CREATE TABLE salary_history (
    history_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL,
    old_salary NUMERIC(10, 2),
    new_salary NUMERIC(10, 2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

--FUNCTION
CREATE FUNCTION log_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO salary_history (employee_id, old_salary, new_salary)
    VALUES (OLD.employee_id, OLD.salary, NEW.salary);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--TRIGGER
CREATE TRIGGER trigger_salary_change
AFTER UPDATE ON employees
FOR EACH ROW
WHEN (OLD.salary IS DISTINCT FROM NEW.salary)
EXECUTE FUNCTION log_salary_change();

--EXAMPLE
-- Insert sample employee
INSERT INTO employees (name, salary) VALUES ('Alice', 50000.00);
-- Update salary (this will trigger logging)
UPDATE employees SET salary = 55000.00 WHERE name = 'Alice';
-- Check history log
SELECT * FROM salary_history;
