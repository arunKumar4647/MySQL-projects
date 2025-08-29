 create database company;
 use company;
 
 -- 1. Employees Table
CREATE TABLE Employees (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50),
    JoinDate DATE,
    Salary DECIMAL(10,2)
);

-- 2. Projects Table
CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    Status VARCHAR(20)
);

-- 3. Tasks Table
CREATE TABLE Tasks (
    TaskID INT PRIMARY KEY,
    ProjectID INT,
    EmpID INT,
    TaskName VARCHAR(100),
    CompletionDate DATE,
    Status VARCHAR(20),
    FOREIGN KEY(ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY(EmpID) REFERENCES Employees(EmpID)
);

-- 4. Sales Table
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    EmpID INT,
    SaleAmount DECIMAL(10,2),
    SaleDate DATE,
    FOREIGN KEY(EmpID) REFERENCES Employees(EmpID)
);

-- 5. Payments Table
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    EmpID INT,
    PaymentMonth VARCHAR(20),
    BaseSalary DECIMAL(10,2),
    Bonus DECIMAL(10,2),
    Commission DECIMAL(10,2),
    TotalPayment DECIMAL(10,2),
    FOREIGN KEY(EmpID) REFERENCES Employees(EmpID)
);

INSERT INTO Employees (EmpID, Name, Department, JoinDate, Salary) VALUES
(101, 'Arjun Mehta', 'Sales', '2022-03-01', 40000.00),
(102, 'Sneha Roy', 'IT', '2021-08-15', 55000.00),
(103, 'Rahul Nair', 'HR', '2023-01-10', 35000.00),
(104, 'Neha Sharma', 'Sales', '2020-11-20', 42000.00),
(105, 'Vikram Das', 'IT', '2022-06-05', 60000.00);

INSERT INTO Projects (ProjectID, ProjectName, StartDate, EndDate, Status) VALUES
(201, 'CRM Development', '2023-01-01', '2023-06-30', 'Completed'),
(202, 'Website Redesign', '2023-05-01', '2023-12-31', 'In Progress'),
(203, 'Employee Portal', '2023-07-01', '2024-01-15', 'In Progress');

INSERT INTO Tasks (TaskID, ProjectID, EmpID, TaskName, CompletionDate, Status) VALUES
(301, 201, 102, 'Login Module', '2023-02-15', 'Completed'),
(302, 201, 105, 'Dashboard UI', '2023-03-20', 'Completed'),
(303, 202, 105, 'Frontend Design', NULL, 'In Progress'),
(304, 203, 102, 'User Registration', NULL, 'Not Started'),
(305, 202, 102, 'Database Integration', NULL, 'In Progress');

INSERT INTO Sales (SaleID, EmpID, SaleAmount, SaleDate) VALUES
(401, 101, 75000.00, '2023-07-15'),
(402, 104, 60000.00, '2023-07-20'),
(403, 101, 85000.00, '2023-08-10'),
(404, 104, 70000.00, '2023-08-22'),
(405, 101, 90000.00, '2023-09-05');

INSERT INTO Payments (PaymentID, EmpID, PaymentMonth, BaseSalary, Bonus, Commission, TotalPayment) VALUES
(501, 101, 'July 2025', 40000.00, 3000.00, 5000.00, 48000.00),
(502, 102, 'July 2025', 55000.00, 4000.00, 0.00, 59000.00),
(503, 103, 'July 2025', 35000.00, 2000.00, 0.00, 37000.00),
(504, 104, 'July 2025', 42000.00, 4500.00, 4000.00, 50500.00),
(505, 105, 'July 2025', 60000.00, 5000.00, 0.00, 65000.00);

#Top 5 Employees by Total Sales
SELECT EmpID, SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY EmpID
ORDER BY TotalSales DESC
LIMIT 5;

#Monthly Payment Report
SELECT EmpID, PaymentMonth, TotalPayment
FROM Payments
ORDER BY EmpID, PaymentMonth;

#Employees with Delayed Tasks
SELECT E.Name, T.TaskName, T.Status
FROM Tasks T
JOIN Employees E ON T.EmpID = E.EmpID
WHERE T.Status != 'Completed';

#Project Completion Status
SELECT ProjectID, 
       COUNT(*) AS TotalTasks,
       SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedTasks,
       ROUND((SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END)*100.0)/COUNT(*), 2) AS CompletionRate
FROM Tasks
GROUP BY ProjectID;

#High Performers with Bonus Above 4000
SELECT EmpID, Bonus
FROM Payments
WHERE Bonus > 4000;

#Average Task Completion Time (per employee)
SELECT EmpID, 
       ROUND(AVG(DATEDIFF(CompletionDate, (SELECT StartDate FROM Projects WHERE ProjectID = T.ProjectID))), 2) AS AvgCompletionDays
FROM Tasks T
WHERE Status = 'Completed'
GROUP BY EmpID;

#Monthly Sales by Department
SELECT E.Department, MONTH(S.SaleDate) AS Month, SUM(S.SaleAmount) AS MonthlySales
FROM Sales S
JOIN Employees E ON S.EmpID = E.EmpID
GROUP BY E.Department, Month;

#Top Employee by Bonus (All Time)
SELECT EmpID, SUM(Bonus) AS TotalBonus
FROM Payments
GROUP BY EmpID
ORDER BY TotalBonus DESC
LIMIT 1;

#Employees Not Assigned Any Tasks
SELECT EmpID, Name
FROM Employees
WHERE EmpID NOT IN (SELECT DISTINCT EmpID FROM Tasks);

#Generate Full Salary Sheet for July 2025
SELECT E.Name, P.BaseSalary, P.Bonus, P.Commission, P.TotalPayment
FROM Payments P
JOIN Employees E ON P.EmpID = E.EmpID
WHERE P.PaymentMonth = 'July 2025';

#List Pairs of Employees Working on the Same Project but Different Tasks
SELECT 
    T1.ProjectID,
    T1.TaskName AS Task_1,
    T2.TaskName AS Task_2,
    T1.EmpID AS Emp_1,
    T2.EmpID AS Emp_2
FROM Tasks T1
JOIN Tasks T2 
  ON T1.ProjectID = T2.ProjectID 
 AND T1.TaskID < T2.TaskID;


ALTER TABLE Projects ADD COLUMN Budget DECIMAL(12,2);

UPDATE Projects SET Budget = 200000 WHERE ProjectID = 201;
UPDATE Projects SET Budget = 300000 WHERE ProjectID = 202;
UPDATE Projects SET Budget = 250000 WHERE ProjectID = 203;

describe projects;

ALTER TABLE Sales ADD COLUMN ProjectID INT;

#profit for project
SELECT 
    P.ProjectID,
    P.ProjectName,
    P.Budget,
    IFNULL(SUM(S.SaleAmount), 0) AS TotalRevenue,
    (IFNULL(SUM(S.SaleAmount), 0) - P.Budget) AS EstimatedProfit
FROM Projects P
LEFT JOIN Sales S ON P.ProjectID = S.ProjectID
GROUP BY P.ProjectID, P.ProjectName, P.Budget;

DESCRIBE Sales;

SELECT * FROM Sales;

UPDATE Sales SET ProjectID = 201 WHERE SaleID = 401;
UPDATE Sales SET ProjectID = 202 WHERE SaleID = 402;
UPDATE Sales SET ProjectID = 203 WHERE SaleID = 403;
UPDATE Sales SET ProjectID = 201 WHERE SaleID = 404;
UPDATE Sales SET ProjectID = 202 WHERE SaleID = 405;
