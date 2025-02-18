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

-- Enable IDENTITY_INSERT for the EnquiryStatus table
--SET IDENTITY_INSERT dbo.EnquiryStatus ON;

MERGE INTO dbo.EnquiryStatus AS Target
USING (VALUES
    (1, 'Submitted'),
    (2, 'Converted'),
    (3, 'Rejected')
) AS Source (EnquiryStatusId, EnquiryStatusName)
ON Source.EnquiryStatusId = Target.EnquiryStatusId
WHEN MATCHED THEN
    UPDATE SET Target.EnquiryStatusName = Source.EnquiryStatusName           
WHEN NOT MATCHED THEN
    INSERT (EnquiryStatusId, EnquiryStatusName)
    VALUES (Source.EnquiryStatusId, Source.EnquiryStatusName);

-- Disable IDENTITY_INSERT for the EnquiryStatus table
--SET IDENTITY_INSERT dbo.EnquiryStatus OFF;