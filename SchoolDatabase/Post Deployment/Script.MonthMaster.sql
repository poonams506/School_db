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
DECLARE @MonthMaster TABLE(MonthMasterId SMALLINT,[MonthName] NVARCHAR(20), MonthNameKey NVARCHAR(20), SortBy SMALLINT);

INSERT INTO @MonthMaster(MonthMasterId,[MonthName],MonthNameKey,SortBy) VALUES(1,'Jan','Jan', 1),
(2,'Feb','Feb', 2),(3,'Mar','Mar', 3),(4,'Apr','Apr', 4),(5,'May','May', 5),(6,'Jun','Jun', 6),(7,'Jul','Jul', 7),(8,'Aug','Aug', 8),(9,'Sept','Sept', 9),(10,'Oct','Oct', 10),
(11,'Nov','Nov', 11),(12,'Dec','Dec', 12);

MERGE INTO MonthMaster AS Target
USING @MonthMaster AS Source 
ON Source.MonthMasterId=Target.MonthMasterId
WHEN MATCHED THEN
UPDATE SET Target.MonthName=Source.MonthName, Target.MonthnameKey = Source.MonthnameKey
WHEN NOT MATCHED THEN
INSERT(MonthMasterId,MonthName,MonthNameKey,SortBy) VALUES(Source.MonthMasterId,Source.MonthName,Source.MonthNameKey,Source.SortBy);
