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
DECLARE @Role TABLE([Name] NVARCHAR(250),[RoleKey] NVARCHAR(250));

INSERT INTO @Role([Name],[RoleKey]) VALUES('Super Admin','Super_Admin'),('Admin','Admin'),('Teacher','Teacher'),('Clerk','Clerk'),('Parent','Parent'),('Cab Driver','Cab_Driver'),('Principal','Principal');

MERGE INTO Role AS Target
USING @Role AS Source 
ON Source.Name=Target.Name
WHEN MATCHED THEN
UPDATE SET Target.Name=Source.Name, Target.RoleKey = Source.RoleKey
WHEN NOT MATCHED THEN
INSERT(Name,RoleKey) VALUES(Source.Name,Source.RoleKey);
