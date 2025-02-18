-- =============================================
-- Author:    Shambala Apugade
-- Create date: 26/08/2023
-- Description:  This stored procedure is used to get dashboard info detail by Id
-- =============================================
CREATE PROC uspDashboardSelect AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
DECLARE @DashboardCountTempTable TABLE(
StudentCount int,
TeacherCount int,
CabDriverCount int,
StaffCount int)

DECLARE @StudentCount int;
SET @StudentCount = (SELECT COUNT (StudentId) FROM Student WHERE IsDeleted<>1  and IsArchive <> 1);

DECLARE @TeacherCount int;
SET @TeacherCount = (SELECT COUNT (TeacherId) FROM Teacher WHERE IsDeleted<>1);

DECLARE @CabDriversCount int;
SET @CabDriversCount = (SELECT COUNT (CabDriverId) FROM CabDriver WHERE IsDeleted<>1);

DECLARE @ClerkCount int;
SET @ClerkCount = (SELECT COUNT (ClerkId) FROM Clerk WHERE IsDeleted<>1);

DECLARE @AdminCount int;
SET @AdminCount = (SELECT COUNT (AdminId) FROM Admin WHERE IsDeleted<>1);

DECLARE @Staff int;
SET @Staff = @TeacherCount+@CabDriversCount+@ClerkCount+@AdminCount

INSERT INTO @DashboardCountTempTable VALUES(@StudentCount, @TeacherCount, @CabDriversCount, @Staff);

DECLARE @DashboardStaffDetailTable table(
StaffName NVARCHAR(200),
Role NVARCHAR(20),
MobileNumber NVARCHAR(20),
Address NVARCHAR(250),
Email VARCHAR(80))

     INSERT INTO @DashboardStaffDetailTable(StaffName, Role, MobileNumber, Address, Email)
     SELECT CONCAT(FirstName,' ',LastName), 'Teacher', MobileNumber, AddressLine1, EmailId FROM Teacher WHERE IsDeleted <> 1
	 
     INSERT INTO @DashboardStaffDetailTable(StaffName, Role, MobileNumber, Address, Email)
     SELECT CONCAT(FirstName,' ',LastName),'Admin',MobileNumber, AddressLine1, EmailId FROM Admin  WHERE IsDeleted <> 1
	 
     INSERT INTO @DashboardStaffDetailTable(StaffName, Role, MobileNumber, Address, Email)
     SELECT CONCAT(FirstName,' ',LastName),'Clerk',MobileNumber, AddressLine1, EmailId FROM Clerk  WHERE IsDeleted <> 1
	 
     INSERT INTO @DashboardStaffDetailTable(StaffName, Role, MobileNumber, Address, Email)
     SELECT CONCAT(FirstName,' ',LastName), 'CabDriver',MobileNumber, AddressLine1, EmailId FROM CabDriver  WHERE IsDeleted <> 1

SELECT * FROM @DashboardCountTempTable 

SELECT ay.AcademicYearName,
COUNT(CASE WHEN Gender = 'M' then 1 End) AS BoysCount,
COUNT(CASE WHEN Gender = 'F' then 1 End)As GirlsCount
FROM AcademicYear ay JOIN School s ON ay.AcademicYearId=s.AcademicYearId 
JOIN Student st ON s.SchoolId =st.SchoolId and st.IsDeleted <> 1 and st.IsArchive <> 1
GROUP BY ay.AcademicYearName

SELECT * FROM @DashboardStaffDetailTable

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
