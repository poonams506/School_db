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
DECLARE @Permission TABLE([PermissionId] INT,[Name] NVARCHAR(250),[PermissionKey] NVARCHAR(250));

INSERT INTO @Permission([PermissionId],[Name],[PermissionKey]) VALUES(1,'Create','Create'),(2,'Read','Read'),(3,'Update','Update'),(4,'Delete','Delete'),(5,'Export','Export'),(6,'Upload','Upload'),(7,'Download','Download'),(8,'Print','Print');

MERGE INTO [Permission] AS Target
USING @Permission AS Source 
ON Source.PermissionId=Target.PermissionId
WHEN MATCHED THEN
UPDATE SET Target.Name=Source.Name,Target.PermissionKey = Source.PermissionKey
WHEN NOT MATCHED THEN
INSERT(PermissionId,Name,PermissionKey) VALUES(Source.PermissionId,Source.Name,Source.PermissionKey);
