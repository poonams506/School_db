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
DECLARE @Title TABLE(TitleId INT,Name NVARCHAR(250), TitleKey NVARCHAR(250));

INSERT INTO @Title(TitleId,Name,TitleKey) VALUES(1,'Mr','Mr'),(2,'Mrs','Mrs'),(3,'Ms','Ms'),(4,'Miss','Miss'),(5,'Master','Master');

MERGE INTO Title AS Target
USING @Title AS Source 
ON Source.TitleId=Target.TitleId
WHEN MATCHED THEN
UPDATE SET Target.Name=Source.Name, Target.TitleKey = Source.TitleKey
WHEN NOT MATCHED THEN
INSERT(TitleId,Name,TitleKey) VALUES(Source.TitleId,Source.Name,Source.TitleKey);
