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
DECLARE @MediumType TABLE(MediumTypeId INT,MediumTypeName NVARCHAR(100), MediumTypeKey NVARCHAR(100));

INSERT INTO @MediumType(MediumTypeId,MediumTypeName,MediumTypeKey) VALUES(1,'English','English'),(2,'Hindi','Hindi'),(3,'Marathi','Marathi'),(4,'Kannad','Kannad');

MERGE INTO MediumType AS Target
USING @MediumType AS Source 
ON Source.MediumTypeId=Target.MediumTypeId
WHEN MATCHED THEN
UPDATE SET Target.MediumTypeName=Source.MediumTypeName, Target.MediumTypeKey = Source.MediumTypeKey
WHEN NOT MATCHED THEN
INSERT(MediumTypeId,MediumTypeName,MediumTypeKey) VALUES(Source.MediumTypeId,Source.MediumTypeName,Source.MediumTypeKey);
