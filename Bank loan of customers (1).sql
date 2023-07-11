USE loan;
SELECT * FROM finance_1;
SELECT * FROM finance_2;

##### KPI 1 - YEAR WISE LOAN AMOUNT STATS #####

SELECT 
  CASE WHEN years IS NULL THEN 'TOTAL' ELSE years END AS years, 
  CONCAT('$ ', FORMAT(SUM(loan_amnt), -2)) AS Total_Loan_amnt 
FROM finance_1 
GROUP BY years WITH ROLLUP;

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

##### KPI 2 - GRADE AND SUB GRADE WISE REVOL_BAL #####
 
 SELECT CASE WHEN GROUPING(grade) = 1 THEN 'Total' ELSE grade END AS grade,
  sub_grade,
  CONCAT('$', ' ', FORMAT(SUM(revol_bal), 2)) AS Revol_bal
FROM finance_1 LEFT JOIN finance_2 ON finance_1.id = finance_2.id GROUP BY grade,
sub_grade WITH ROLLUP ORDER BY grade;


##### KPI 3 - Total Payment for Verified Status Vs Total Payment for Non Verified Status #####

SELECT CASE WHEN GROUPING(verification_status) = 1 THEN 'TOTAL' ELSE verification_status END AS verification_status,
  CONCAT('$', ' ', ROUND(SUM(total_pymnt), -2)) AS Total_Payment
FROM finance_1 LEFT JOIN finance_2 ON finance_1.id = finance_2.id 
WHERE verification_status IN ('Not Verified', 'Verified')
GROUP BY verification_status WITH ROLLUP;


##### KPI 4 - State wise and last_credit_pull_d wise loan status #####

SELECT addr_state, last_credit_pull_d, 
SUM(CASE WHEN loan_status = "Fully Paid" THEN 1 ELSE 0 END) AS "Fully Paid",
SUM(CASE WHEN loan_status = "Charged off" THEN 1 ELSE 0 END) AS "Charged off",
SUM(CASE WHEN loan_status = "Current" THEN 1 ELSE 0 END) AS "Current"
FROM finance_1
INNER JOIN finance_2 ON finance_1.id = finance_2.id
GROUP BY addr_state, last_credit_pull_d, loan_status
ORDER BY addr_state;


##### KPI 5 - Home ownership Vs last payment date stats #####

SELECT finance_2.last_pymnt_d as Last_Payment_Date,
  finance_1.home_ownership,
  CONCAT('$ ', FORMAT(SUM(finance_2.last_pymnt_amnt), 2)) as 'Total_Payment'
FROM finance_1
JOIN finance_2
ON finance_1.id = finance_2.id
WHERE finance_1.home_ownership IN ('RENT', 'MORTGAGE', 'OWN', 'OTHER', 'NONE')
GROUP BY finance_1.home_ownership
HAVING SUM(finance_2.last_pymnt_amnt) != 0
ORDER BY finance_2.last_pymnt_d, SUM(finance_2.last_pymnt_amnt) DESC;

