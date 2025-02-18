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
DECLARE @AcademicYear TABLE(AcademicYearId INT,AcademicYearName NVARCHAR(100), AcademicYearKey NVARCHAR(100));

INSERT INTO @AcademicYear(AcademicYearId,AcademicYearName,AcademicYearKey) 
VALUES
(1,'2020-2021','AY2021'),
(2,'2021-2022','AY2022'),
(3,'2022-2023','AY2023'),
(4,'2023-2024','AY2024'),
(5,'2024-2025','AY2025'),
(6,'2025-2026','AY2026'),
(7,'2026-2027','AY2027'),
(8,'2027-2028','AY2028'),
(9,'2028-2029','AY2029'),
(10,'2029-2030','AY2030'),
(11,'2030-2031','AY2031'),
(12,'2031-2032','AY2032'),
(13,'2032-2033','AY2033'),
(14,'2033-2034','AY2034'),
(15,'2034-2035','AY2035'),
(16,'2035-2036','AY2036'),
(17,'2036-2037','AY2037'),
(18,'2037-2038','AY2038'),
(19,'2038-2039','AY2039'),
(20,'2039-2040','AY2040'),
(21,'2040-2041','AY2041'),
(22,'2041-2042','AY2042'),
(23,'2042-2043','AY2043'),
(24,'2043-2044','AY2044'),
(25,'2044-2045','AY2045'),
(26,'2045-2046','AY2046'),
(27,'2046-2047','AY2047'),
(28,'2047-2048','AY2048'),
(29,'2048-2049','AY2049'),
(30,'2049-2050','AY2050'),
(31,'2050-2051','AY2051');

MERGE INTO AcademicYear AS Target
USING @AcademicYear AS Source 
ON Source.AcademicYearId=Target.AcademicYearId
WHEN MATCHED THEN
UPDATE SET Target.AcademicYearName=Source.AcademicYearName, Target.AcademicYearKey = Source.AcademicYearKey
WHEN NOT MATCHED THEN
INSERT(AcademicYearId,AcademicYearName,AcademicYearKey) VALUES(Source.AcademicYearId,Source.AcademicYearName,Source.AcademicYearKey);
