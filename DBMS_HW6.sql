/*
Erin Zahner 
DB Assignment 6
10 December 2024
*/

-- The beginning of this is from what was provided for us, the second half is edited to fit the criteria of the assignment


-- Create the accounts table
CREATE TABLE accounts (
  account_num CHAR(5) PRIMARY KEY,    -- 5-digit account number (e.g., 00001, 00002, ...)
  branch_name VARCHAR(50),            -- Branch name (e.g., Brighton, Downtown, etc.)
  balance DECIMAL(10, 2),             -- Account balance, with two decimal places (e.g., 1000.50)
  account_type VARCHAR(50)            -- Type of the account (e.g., Savings, Checking)
);



-- =============================================================================================================
-- Stored Procedure to generate accounts 
-- =============================================================================================================

-- Change delimiter to allow semicolons inside the procedure
DELIMITER $$

CREATE PROCEDURE generate_accounts()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE branch_name VARCHAR(50);
  DECLARE account_type VARCHAR(50);
  
  -- Loop to generate 50,000 account records
  WHILE i <= 150000 DO
    -- Randomly select a branch from the list of branches
    SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    
    -- Randomly select an account type
    SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
    
    -- Insert account record
    INSERT INTO accounts (account_num, branch_name, balance, account_type)
    VALUES (
      LPAD(i, 5, '0'),                   -- Account number as just digits, padded to 5 digits (e.g., 00001, 00002, ...)
      branch_name,                       -- Randomly selected branch name
      ROUND((RAND() * 100000), 2),       -- Random balance between 0 and 100,000, rounded to 2 decimal places
      account_type                       -- Randomly selected account type (Savings/Checking)
    );

    SET i = i + 1;
  END WHILE;
END$$

-- Reset the delimiter back to the default semicolon
DELIMITER ;

-- =============================================================================================================
-- execute the procedure
-- =============================================================================================================
CALL generate_accounts();


-- =============================================================================================================
-- Indexes Used in Analysis
-- =============================================================================================================

CREATE INDEX idx_branch_name ON accounts (branch_name);
CREATE INDEX idx_account_type ON accounts (account_type);
CREATE INDEX idx_balance ON accounts (balance);

DROP INDEX idx_branch_name ON accounts;
DROP INDEX idx_account_type ON accounts;
DROP INDEX idx_balance ON accounts;


-- =============================================================================================================
-- Stored Procedure to measure average exectution time 
-- =============================================================================================================

DELIMITER $$
CREATE PROCEDURE measure_avg_execution_time(IN query_str TEXT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE total_time BIGINT DEFAULT 0;
    DECLARE avg_time BIGINT;
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    
    -- Declare stmt as a session variable 
    SET @stmt = query_str;

    -- Loop to execute the query 10 times
    WHILE i <= 10 DO
        -- Capture start time
        SET start_time = NOW(6);

        -- Prepare the statement from the query string
        PREPARE dynamic_stmt FROM @stmt;

        -- Execute the dynamic statement
        EXECUTE dynamic_stmt;

        -- Deallocate the prepared statement
        DEALLOCATE PREPARE dynamic_stmt;

        -- Capture end time
        SET end_time = NOW(6);
        
        -- Calculate the time difference in microseconds
        SET total_time = total_time + TIMESTAMPDIFF(MICROSECOND, start_time, end_time);
        
        SET i = i + 1;
    END WHILE;

    -- Calculate the average time and return the result
    SET avg_time = total_time / 10;
    SELECT avg_time AS average_execution_time_microseconds;
END$$

DELIMITER ;

CALL measure_avg_execution_time('SELECT count(*) FROM accounts WHERE branch_name = "Downtown" AND balance = 50000');
CALL measure_avg_execution_time('SELECT count(*) FROM accounts WHERE branch_name = "Downtown" AND balance BETWEEN 10000 AND 5000;');




