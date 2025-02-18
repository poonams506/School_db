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
DECLARE @UserRole TABLE([UserId] INT,[RoleId] INT, [RefId] INT);

INSERT INTO @UserRole([UserId],[RoleId],[RefId]) VALUES(1,1,1);

MERGE INTO [UserRole] AS Target
USING @UserRole AS Source 
ON Source.UserId=Target.UserId AND Source.RoleId=Target.RoleId
WHEN MATCHED THEN
UPDATE SET Target.RefId=Source.RefId
WHEN NOT MATCHED THEN
INSERT([UserId],[RoleId],[RefId]) 
VALUES(Source.UserId,Source.RoleId,Source.RefId);
