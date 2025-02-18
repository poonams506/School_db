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
:r .\Script.Title.sql
:r .\Script.Role.sql
:r .\Script.User.sql
:r .\Script.UserRole.sql
:r .\Script.Permission.sql
:r .\Script.Module.sql
:r .\Script.RolePermission.sql
:r .\Script.MediumType.sql
:r .\Script.Country.sql
:r .\Script.State.sql
:r .\Script.District.sql
:r .\Script.Taluka.sql
:r .\Script.AcademicYear.sql
:r .\Script.MonthMaster.sql
:r .\Script.ExamTerm.sql
:r .\Script.ExamType.sql
:r .\Script.EnquiryType.sql
:r .\Script.EnquiryStatus.sql