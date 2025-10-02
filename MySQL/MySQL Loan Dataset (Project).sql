USE shamila_db;

SHOW TABLES;

SELECT * FROM loan_project;

# BASIC DATA RETRIEVAL

# 1. What is the total number of loans in the dataset ?

SELECT count(*) AS TOTAL_NUMBER_OF_LOANS FROM loan_project;

# 2. What are the details of all loans with a loan amount greater than 500?

SELECT * FROM loan_project WHERE LoanAmount > 500;

# 3. How many loans are approved (LoanStatus = 'Y') ?

SELECT count(*) AS TOTAL_NUMBER_OF_APPROVED_LOAN FROM loan_project WHERE LoanStatus = 'Y';

# 4. What is the average loan amount for all loans ?

SELECT avg(LoanAmount) AS AVG_LOAN_AMOUNT FROM loan_project;

# GROUPING AND AGGREGATING

# 5. What is the average loan amount for male and female applicants ?

SELECT Gender , avg(LoanAmount) AS AVG_LOAN_AMOUNT FROM loan_project GROUP BY Gender;

# 6. What is the total loan amount for each property area ?

SELECT PropertyArea , sum(LoanAmount) AS TOTAL_LOAN_AMOUNT FROM loan_project GROUP BY PropertyArea;

# 7. How many loans where approved for applicants with a credit history of 1 ?

SELECT count(*) AS COUNT_APPROVED FROM loan_project WHERE CreditHistory = 1 AND  LoanStatus = 'Y';

# 8. What is the average applicant income for married v/s unmarried individuals ?

SELECT Married , avg(ApplicantIncome) AS AVG_INCOME FROM loan_project GROUP BY Married;

# CONDITIONS AND FILTERING

# 9. Which loans have a term greater than 20 years and are approved ?

SELECT * FROM loan_project WHERE LoanAmountTerm > 240 AND LoanStatus = 'Y';

# 10. How many loans are granted to self-employed applicants compared to non-self-employed applicants ?

SELECT SelfEmployed , count(*) AS TOTAL_COUNT FROM loan_project GROUP BY SelfEmployed;

# 11. What is the average loan amount for applicants with credit history of 0 ?

SELECT avg(LoanAmount) FROM loan_project WHERE CreditHistory = 0;

# 12. Which loan have been rejected (LoanStatus = 'N') and what is the gender distribution ?

SELECT Gender , count(*) AS REJECTED_COUNT FROM loan_project WHERE LoanStatus = 'N' GROUP BY Gender;

# JOINS AND RELATIONSHIPS 

# 13. How many applicants have dependents ?

SELECT Dependents , count(*) AS TOTAL_COUNT FROM loan_project WHERE Dependents = 1 OR Dependents = 2 GROUP BY Dependents;

# 14. What is the total loan amount for each combination of education level and marital status ?

SELECT Education , Married , sum(LoanAmount) AS TOTAL_LOAN_AMOUNT FROM loan_project GROUP BY Education , Married;

# 15. Which property area has the highest average loan amount ?

SELECT PropertyArea , avg(LoanAmount) AS AVG_LOAN_AMOUNT FROM loan_project GROUP BY PropertyArea ORDER BY AVG_LOAN_AMOUNT DESC LIMIT 1;

# 16. Who have the loans with both an applicant income greater than 50000 and a loan amount less than 600 ?

SELECT * FROM loan_project WHERE ApplicantIncome > 50000 AND LoanAmount < 600;

# SORTNG AND RANKING

# 17. What are the top 5 loan amounts granted to the applicants with the highest credit history ?

SELECT * FROM loan_project WHERE CreditHistory = 1 ORDER BY LoanAmount DESC LIMIT 5;

# 18. Which 3 applicants have the highest combined income (ApplicantIncome + CoapplicantIncome) ?

SELECT LoanID , Gender , ApplicantIncome + CoapplicantIncome AS TOTAL_INCOME FROM loan_project ORDER BY TOTAL_INCOME DESC LIMIT 3;

# 19. List the top 5 applicants with longest loan term and the correspoding loan amount ?

SELECT LoanID , LoanAmount , LoanAmountTerm FROM loan_project ORDER BY LoanAmountTerm DESC LIMIT 5;

# ADVANCED ANALYSIS

# 20. What is the average loan amount for applicants with and without dependents ?

SELECT Dependents , avg(LoanAmount) AS AVG_LOAN_AMOUNT FROM loan_project GROUP BY Dependents;

# 21. What percentage of loans were granted to aplicants with a credit hitory of 1 ?

SELECT (count(*) * 100 / (SELECT count(*) FROM loan_project)) AS PERCENTAGE FROM loan_project WHERE CreditHistory = 1;

# 22. What is the average loan amount for applicants in each combination of gender , education , and marital status ?

 SELECT Gender , Education , Married , avg(LoanAmount) AS AVG_LOAN_AMOUNT FROM loan_project GROUP BY Gender , Education , Married;
 
 # 23. Which applicants have the highest loan amount and the lowest income ?
 
 SELECT LoanID , LoanAmount , ApplicantIncome + CoapplicantIncome AS TOTAL_INCOME FROM loan_project ORDER BY LoanAmount DESC , TOTAL_INCOME ASC LIMIT 5;
 
 # 24. How many applicants were granted loans with a term of more than 15 years (180 months) in each property area ?
 
 SELECT PropertyArea , count(*) AS TOTAL_COUNT FROM loan_project WHERE LoanAmountTerm > 180 AND LoanStatus = 'Y' GROUP BY PropertyArea;
 
 # STORED PROCEDURE
 
 # Stored procedure to calculate the total loan amount ny loan amount term.
 
DELIMITER //

CREATE PROCEDURE GetTotalLoanAmountByLoanTerm()

BEGIN
	SELECT LoanAmountTerm , sum(LoanAmount) AS TOTAL_LOAN_AMOUNT
    FROM loan_project
    GROUP BY LoanAmountTerm;
END // 

DELIMITER ;

CALL GetTotalLoanAmountByLoanTerm();

# Stored procedure to get total loan amount based on loan status. (USING IN PARAMETER)

DELIMITER &&

CREATE PROCEDURE GetTotalAmountByStatus(IN loan_status VARCHAR(10))

BEGIN
	SELECT sum(LoanAmount) AS TOTAL_LOAN_AMOUNT
    FROM loan_project
    WHERE LoanStatus = loan_status;
END &&

DELIMITER ; 

CALL GetTotalAmountByStatus('Y');

# Stored proedure to get the total loan amount for a specific gender. (USING OUT PARAMETER)

DELIMITER //

CREATE PROCEDURE GetLoanAmountByGender(IN loan_gender VARCHAR(10) , OUT total_loan_amount DECIMAL(10,2))

BEGIN
	SELECT sum(LoanAmount) INTO total_loan_amount
    FROM loan_project
    WHERE Gender = loan_gender;
END //

DELIMITER ;

-- Declare a variable to hold the output value
SET @total_amount = 0;

-- Call the stored procedure
CALL GetLoanAmountByGender('Male',@total_amount);

-- Display the result
SELECT @total_amount AS TOTAL_LOAN_AMOUNT;

# Stored procedure to calculate and update total loan amount based on gender. (USING INOUT PARAMETER)

DELIMITER &&

CREATE PROCEDURE UpdateLoanAmountByGender(INOUT total_loan_amount DECIMAL(10,2),IN loan_gender varchar(10))

BEGIN
	SELECT sum(LoanAmount) INTO total_loan_amount
    FROM loan_project
    WHERE Gender = loan_gender;
END &&

DELIMITER ;

-- Declare a variable to hold the output value
SET @total_amount = 0;

-- Call the stored procedure
CALL UpdateLoanAmountByGender(@total_amount,'Male');

-- Display the result
SELECT @total_amount AS UPDATED_TOTAL_LOAN_AMOUNT;

# TRIGGER

# Trigger to check applicant income and update loan status. (USING AFTER INSERT)

DELIMITER //

CREATE TRIGGER CheckApplicantIncome
AFTER INSERT ON loan_project
FOR EACH ROW

BEGIN
	IF NEW.ApplicantIncome < 20000 THEN
		UPDATE loan_project
        SET LoanStatus = 'N'
        WHERE LoanID = NEW.LoanID;
	END IF;
END //

DELIMITER ;

SET sql_safe_updates = 0;

UPDATE loan_project
SET ApplicantIncome = 15000, LoanStatus = 'N'
WHERE LoanID = 'LP001003';

SELECT LoanID, ApplicantIncome, LoanStatus
FROM loan_project
WHERE LoanID = 'LP001003';

# Trigger to automatically update credit history based on loan status. (USING AFTER UPDATE)

DELIMITER &&

CREATE TRIGGER UpdateCreditHistoryOnLoanAmountChange
AFTER UPDATE ON loan_project
FOR EACH ROW

BEGIN 
	IF NEW.LoanStatus = 'N' THEN
		UPDATE loan_project
        SET CreditHistory = 0
        WHERE LoanID = NEW.LoanID;
	END IF ;
END &&

DELIMITER ;

SET sql_safe_updates = 0;

UPDATE loan_project
SET LoanStatus = 'N'
WHERE LoanID = 'LP001047';

SELECT LoanID, LoanStatus, CreditHistory
FROM loan_project
WHERE LoanID = 'LP001047'; 

  