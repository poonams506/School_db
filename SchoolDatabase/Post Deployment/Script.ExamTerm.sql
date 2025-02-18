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
-- Enable IDENTITY_INSERT for the Term table
SET IDENTITY_INSERT dbo.CBSE_Term ON;

MERGE INTO dbo.CBSE_Term AS Target
USING (VALUES
    (1, 'First Term'),
    (2, 'Second Term')
) AS Source (TermId, TermName)
ON Source.TermId = Target.TermId  -- Match on TermId instead of TermName
WHEN MATCHED THEN
    UPDATE SET Target.TermName = Source.TermName           
WHEN NOT MATCHED THEN
    INSERT (TermId, TermName)
    VALUES (Source.TermId, Source.TermName);

-- Disable IDENTITY_INSERT for the Term table
SET IDENTITY_INSERT dbo.CBSE_Term OFF;
