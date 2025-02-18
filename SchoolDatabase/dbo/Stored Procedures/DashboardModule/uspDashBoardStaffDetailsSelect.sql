-- =============================================
-- Author:    Shambala Apugade
-- Create date: 12/10/2023
-- Description:  This stored procedure is used to get dashboard info detail by Id
-- =============================================
CREATE PROC uspDashBoardStaffDetailsSelect AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
DECLARE @DashboardStaffDetailTable table(
StaffName NVARCHAR(200),
Role NVARCHAR(20),
MobileNumber NVARCHAR(20),
Address NVARCHAR(250),
Email VARCHAR(80))

     INSERT INTO @DashboardStaffDetailTable(StaffName, Role, MobileNumber, Address, Email)
     SELECT CONCAT(FirstName,' ',LastName), 'Teacher', MobileNumber, AddressLine1, EmailId FROM Teacher WHERE IsDeleted<>1
	 
     INSERT INTO @DashboardStaffDetailTable(StaffName, Role, MobileNumber, Address, Email)
     SELECT CONCAT(FirstName,' ',LastName),'Admin',MobileNumber, AddressLine1, EmailId FROM Admin WHERE IsDeleted<>1
	 
     INSERT INTO @DashboardStaffDetailTable(StaffName, Role, MobileNumber, Address, Email)
     SELECT CONCAT(FirstName,' ',LastName),'Clerk',MobileNumber, AddressLine1, EmailId FROM Clerk WHERE IsDeleted<>1
	 
     INSERT INTO @DashboardStaffDetailTable(StaffName, Role, MobileNumber, Address, Email)
     SELECT CONCAT(FirstName,' ',LastName), 'CabDriver',MobileNumber, AddressLine1, EmailId FROM CabDriver WHERE IsDeleted<>1

SELECT * FROM @DashboardStaffDetailTable ORDER BY StaffName ASC;

END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
DECLARE @ErrorState INT = ERROR_STATE();
DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();
DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
EXEC uspExceptionLogInsert @ErrorLine,
@ErrorMessage,
@ErrorNumber,
@ErrorProcedure,
@ErrorSeverity,
@ErrorState END CATCH
END	 
