CREATE DATABASE Employee;
USE Employee;

-- Data Validation Queries
SELECT * FROM employee_data;
SELECT * FROM feedback_data;
SELECT * FROM performance_metrics;
SELECT * FROM training_data;


-- DATA ALTERATION
-- Converting the data type and add constraints

DESC employee_data;
ALTER TABLE employee_data
MODIFY Hire_Date DATE;
ALTER TABLE employee_data
ADD CONSTRAINT PRIMARY KEY (Employee_ID);

DESC feedback_data;
ALTER TABLE feedback_data
MODIFY Feedback_Date DATE;
ALTER TABLE feedback_data
ADD CONSTRAINT PRIMARY KEY (Feedback_ID);
ALTER TABLE feedback_data
ADD CONSTRAINT FOREIGN KEY (Employee_ID) REFERENCES employee_data(Employee_ID);

DESC performance_metrics;
ALTER TABLE performance_metrics
MODIFY Performance_Review_Date DATE;
ALTER TABLE performance_metrics
ADD CONSTRAINT PRIMARY KEY (Metric_ID);
ALTER TABLE performance_metrics
ADD CONSTRAINT FOREIGN KEY (Employee_ID) REFERENCES employee_data(Employee_ID);


DESC training_data;
ALTER TABLE training_data
MODIFY Completion_Date DATE;
ALTER TABLE training_data
ADD CONSTRAINT PRIMARY KEY (Training_ID);
ALTER TABLE training_data
ADD CONSTRAINT FOREIGN KEY (Employee_ID) REFERENCES employee_data(Employee_ID);


-- Exploratorty Data Analysis

-- 1) Employee Count by Department

SELECT Department, COUNT(*) FROM employee_data
GROUP BY Department;

/* This data show the total employee in each department.*/

-- 2) Feedback Analysis

SELECT Feedback_Type, COUNT(*) FROM feedback_data
GROUP BY Feedback_Type;

/* This data shows that mostly employeer received good remarks.*/

-- 3) Average Project Completion Rate by Department

SELECT 
    E.Department,
    AVG(P.Project_Completion_Rate) AS AVG_Completion_Rate
FROM
    employee_data E
        JOIN
    performance_metrics P ON E.Employee_ID = P.Employee_ID
GROUP BY E.Department
ORDER BY AVG_Completion_Rate DESC;

/* This data Identifies which departments are completing projects efficiently.*/

-- 4) Total Tasks Completed by Employee (Top Performers)

SELECT 
    E.Employee_ID, E.Name, E.Department, P.Total_Tasks_Completed
FROM
    employee_data E
        JOIN
    performance_metrics P ON E.Employee_ID = P.Employee_ID
ORDER BY P.Total_Tasks_Completed DESC
LIMIT 10;

/* This data Identifies high-performing employees based on task completion.*/

-- 5)Average Training Hours by Department

SELECT 
    E.Department,
    ROUND(AVG(T.Training_Hours), 2) AS AVG_Training_Hour
FROM
    employee_data E
        JOIN
    training_data T ON E.Employee_ID = t.Employee_ID
    GROUP BY E.Department
ORDER BY AVG_Training_Hour DESC;

/* This data Identifies which departments invest more in employee training.*/

-- 6) Correlation Between Training & Performance

SELECT 
    E.Employee_ID,
    E.Name,
    SUM(T.Training_Hours) AS Total_Training_Hour,
    AVG(P.Project_Completion_Rate) AS AVG_Completion_Rate
FROM
    employee_data E
        JOIN
    training_data T ON E.Employee_ID = T.Employee_ID
        JOIN
    performance_metrics P ON E.Employee_ID = P.Employee_ID
    GROUP BY E.Employee_ID , E.Name
ORDER BY Total_Training_Hour DESC;

/* This data Analyzes whether more training improves project completion rates.*/

-- 7) Employees with High Training but Low Performance

SELECT 
    E.Employee_ID,
    E.Name,
    SUM(T.Training_Hours) AS Total_Training_Hour,
    AVG(P.Project_Completion_Rate) AS AVG_Completion_Rate
FROM
    employee_data E
        JOIN
    training_data T ON E.Employee_ID = T.Employee_ID
        JOIN
    performance_metrics P ON E.Employee_ID = P.Employee_ID
GROUP BY E.Employee_ID , E.Name
HAVING AVG_Completion_Rate < 80
ORDER BY Total_Training_Hour DESC;

/* This data helps identifying employees who need more attention.*/

-- 8) Employee Ranking Based on Multiple KPIs

SELECT 
    E.Name,
    E.Department,
    P.Project_Completion_Rate,
    P.Total_Tasks_Completed,
    P.Employee_Satisfaction_Score,
    ROUND((P.Project_Completion_Rate * 0.4 + P.Total_Tasks_Completed * 0.3 + P.Employee_Satisfaction_Score * 0.3),
            2) AS Performance_Score
FROM
    employee_data E
        JOIN
    performance_metrics P ON E.Employee_ID = P.Employee_ID
ORDER BY Performance_Score DESC
LIMIT 10;

/* This data Provides a holistic performance ranking of employees based on Project Completion Rate, Tasks Completed, and Satisfaction Score. */

-- 9) Employee Tenure Classification

SELECT E.Name, E.Department, E.Hire_Date,
       CASE 
           WHEN DATEDIFF(CURDATE(), E.Hire_Date) / 365 BETWEEN 4 AND 8 THEN 'Old Employee (4-8 years)'
           WHEN DATEDIFF(CURDATE(), E.Hire_Date) / 365 BETWEEN 2 AND 4 THEN 'Intermediate (2-4 years)'
           ELSE 'New Joinee (0-2 years)'
       END AS Employee_Tenure
FROM employee_data E;

/* This data Helps in workforce planning by categorizing employees based on experience. */

-- 10) Bonus Eligibility Based on Performance

 SELECT E.Name, E.Department, P.Project_Completion_Rate, P.Total_Tasks_Completed,
P.Employee_Satisfaction_Score, 
ROUND(P.Project_Completion_Rate * 0.4 + P.Total_Tasks_Completed * 0.3 +
P.Employee_Satisfaction_Score * 0.3) AS Performance_Score,
CASE 
WHEN (P.Project_Completion_Rate * 0.4 + P.Total_Tasks_Completed * 0.3 + P.Employee_Satisfaction_Score * 0.3) >= 50 
AND p.Employee_Satisfaction_Score >= 4.5 THEN 'Eligible'
ELSE 'Not Eligible'
END AS Bonus_Eligibility
FROM employee_data E
JOIN performance_metrics P ON E.Employee_ID = P.Employee_ID;

/* This data identifies employees who should receive performance-based bonuses.*/

-- 11) Count no.of eligible and not eligible employee for bonus.

SELECT 
    COUNT(CASE WHEN (P.Project_Completion_Rate * 0.4 + P.Total_Tasks_Completed * 0.3 + P.Employee_Satisfaction_Score * 0.3) >= 50
               AND P.Employee_Satisfaction_Score >= 4.5 THEN 1 END) AS Eligible_For_Bonus,
    COUNT(CASE WHEN (P.Project_Completion_Rate * 0.4 + P.Total_Tasks_Completed * 0.3 + P.Employee_Satisfaction_Score * 0.3) < 50 
               OR P.Employee_Satisfaction_Score < 4.5 THEN 1 END) AS Not_Eligible_For_Bonus
FROM employee_data E
JOIN performance_metrics P ON E.Employee_ID = P.Employee_ID;

 /* This data shows no.of employees who received performance-based bonuses.*/

