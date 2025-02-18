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
DECLARE @Country TABLE(CountryId INT,CountryName NVARCHAR(100), CountryKey NVARCHAR(100));

INSERT INTO @Country(CountryId,CountryName,CountryKey) VALUES(1,'India','India');

MERGE INTO Country AS Target
USING @Country AS Source 
ON Source.CountryId=Target.CountryId
WHEN MATCHED THEN
UPDATE SET Target.CountryName=Source.CountryName, Target.CountryKey = Source.CountryKey
WHEN NOT MATCHED THEN
INSERT(CountryId,CountryName,CountryKey) VALUES(Source.CountryId,Source.CountryName,Source.CountryKey);
