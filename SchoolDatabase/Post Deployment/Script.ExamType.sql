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
SET IDENTITY_INSERT dbo.CBSE_ExamType ON;

MERGE INTO dbo.CBSE_ExamType AS Target
USING (VALUES
    (1, 'Formative'),
    (2, 'Summative'),
    (3, 'Unit')
) AS Source (ExamTypeId, ExamTypeName)
ON Source.ExamTypeId = Target.ExamTypeId
WHEN MATCHED THEN
    UPDATE SET Target.ExamTypeName = Source.ExamTypeName           
WHEN NOT MATCHED THEN
    INSERT (ExamTypeId, ExamTypeName)
    VALUES (Source.ExamTypeId, Source.ExamTypeName);

-- Disable IDENTITY_INSERT for the Shop table
SET IDENTITY_INSERT dbo.CBSE_ExamType OFF;	