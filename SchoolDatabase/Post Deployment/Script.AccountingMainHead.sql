/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

-- Enable IDENTITY_INSERT for the AccountingMainHead table
SET IDENTITY_INSERT dbo.AccountingMainHead ON;

MERGE INTO dbo.AccountingMainHead AS Target
USING (VALUES
    (1, 'Bank Accounts'),
    (2, 'Bank OCC A/C'),
    (3, 'Bank OD A/C'),
    (4, 'Branch / Divisions'),
    (5, 'Capital Account'),
    (6, 'Cash-in-Hand'),
    (7, 'Current Assets'),
    (8, 'Current Liabilities'),
    (9, 'Deposits (Asset)'),
    (10, 'Direct Expenses'),
    (11, 'Direct Incomes'),
    (12, 'Duties & Taxes'),
    (13, 'Expenses (Direct)'),
    (14, 'Expenses (Indirect)'),
    (15, 'Fixed Assets'),
    (16, 'Income (Direct)'),
    (17, 'Income (Indirect)'),
    (18, 'Indirect Expenses'),
    (19, 'Indirect Incomes'),
    (20, 'Investments'),
    (21, 'Loans & Advances (Asset)'),
    (22, 'Loans (Liability)'),
    (23, 'Misc. Expenses (ASSET)'),
    (24, 'Provisions'),
    (25, 'Purchase Accounts'),
    (26, 'Reserves & Surplus'),
    (27, 'Retained Earnings'),
    (28, 'Sales Accounts'),
    (29, 'Secured Loans'),
    (30, 'Stock-in-Hand'),
    (31, 'Sundry Creditors'),
    (32, 'Sundry Debtors'),
    (33, 'Suspense A/c'),
    (34, 'Unsecured Loans')
) AS Source (AccountingMainHeadId, Name)
ON Source.AccountingMainHeadId = Target.AccountingMainHeadId
WHEN MATCHED THEN
    UPDATE SET Target.Name = Source.Name           
WHEN NOT MATCHED THEN
    INSERT (AccountingMainHeadId, Name)
    VALUES (Source.AccountingMainHeadId, Source.Name);

-- Disable IDENTITY_INSERT for the AccountingMainHead table
SET IDENTITY_INSERT dbo.AccountingMainHead OFF;