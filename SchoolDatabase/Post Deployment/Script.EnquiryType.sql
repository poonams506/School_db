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

-- Enable IDENTITY_INSERT for the EnquiryType table
--SET IDENTITY_INSERT dbo.EnquiryType ON;

MERGE INTO dbo.EnquiryType AS Target
USING (VALUES
    (1, 'Internal'),
    (2, 'External')
) AS Source (EnquiryTypeId, EnquiryTypeName)
ON Source.EnquiryTypeId = Target.EnquiryTypeId
WHEN MATCHED THEN
    UPDATE SET Target.EnquiryTypeName = Source.EnquiryTypeName           
WHEN NOT MATCHED THEN
    INSERT (EnquiryTypeId, EnquiryTypeName)
    VALUES (Source.EnquiryTypeId, Source.EnquiryTypeName);

-- Disable IDENTITY_INSERT for the EnquiryType table
--SET IDENTITY_INSERT dbo.EnquiryType OFF;