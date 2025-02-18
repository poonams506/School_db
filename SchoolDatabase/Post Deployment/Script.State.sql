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
DECLARE @State TABLE(StateId INT,CountryId INT, StateName NVARCHAR(100), StateKey NVARCHAR(100));

INSERT INTO @State(StateId,CountryId,StateName,StateKey) VALUES(1,1,'Maharashtra','Maharashtra'),(2,1,'Karnataka','Karnataka'),(3,1,'Andhra Pradesh','Andhra_Pradesh'),(4,1,'Arunachal Pradesh','Arunachal_Pradesh'),(5,1,'Assam','Assam'),(6,1,'Bihar','Bihar'),(7,1,'Chhattisgarh','Chhattisgarh'),(8,1,'Goa','Goa'),
(9,1,'Gujarat','Gujarat'),(10,1,'Haryana','Haryana'),(11,1,'Himachal Pradesh','Himachal_Pradesh'),(12,1,'Jharkhand','Jharkhand'),(13,1,'Kerala','Kerala'),
(14,1,'Madhya Pradesh','Madhya_Pradesh'),(15,1,'Manipur','Manipur'),(16,1,'Meghalaya','Meghalaya'),(17,1,'Mizoram','Mizoram'),(18,1,'Nagaland','Nagaland'),
(19,1,'Odisha','Odisha'),(20,1,'Punjab','Punjab'),(21,1,'Sikkim','Sikkim'),(22,1,'Tamil Nadu','Tamil_Nadu'),(23,1,'Telangana','Telangana'),
(24,1,'Tripura','Tripura'),(25,1,'Uttarakhand','Uttarakhand'),(26,1,'Uttar Pradesh','Uttar_Pradesh'),(27,1,'West Bengal','West_Bengal'),(28,1,'Rajasthan','Rajasthan'),
(29,1,'Andaman and Nicobar Islands','Andaman_and_Nicobar_Islands'),(30,1,'Dadra and Nagar Haveli and Daman Diu','Dadra_and_Nagar_Haveli_and_Daman_Diu'),(31,1,'The Government of NCT of Delhi','The_Government_of_NCT_of_Delhi'),
(32,1,'Jammu And Kashmir','Jammu_Kashmir'),(33,1,'Ladakh','Ladakh'),(34,1,'Lakshadweep','Lakshadweep'),(35,1,'Puducherry','Puducherry');

MERGE INTO State AS Target
USING @State AS Source 
ON Source.StateId=Target.StateId
WHEN MATCHED THEN
UPDATE SET Target.StateName=Source.StateName, Target.StateKey = Source.StateKey, Target.CountryId = Source.CountryId
WHEN NOT MATCHED THEN
INSERT(StateId,CountryId,StateName,StateKey) VALUES(Source.StateId,Source.CountryId,Source.StateName,Source.StateKey);
