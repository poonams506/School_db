-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 07/05/2024
-- Description:  This stored procedure is used to get all staff
-- =============================================
CREATE PROC uspTransportStaffSelect
AS
BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 

NOCOUNT ON;
BEGIN TRY 
DECLARE @StaffTable table(StaffId NVARCHAR(50),StaffName NVARCHAR(150))

     INSERT INTO @StaffTable(StaffId, StaffName)
     SELECT CONCAT(3,'_',TeacherId),CONCAT(FirstName,' ',LastName)
     FROM dbo.Teacher WHERE IsDeleted<>1;

     INSERT INTO @StaffTable(StaffId, StaffName)
     SELECT CONCAT(2,'_',AdminId),CONCAT(FirstName,' ',LastName)
     FROM dbo.[Admin] WHERE IsDeleted<>1;

     INSERT INTO @StaffTable(StaffId, StaffName)
     SELECT CONCAT(4,'_',ClerkId),CONCAT(FirstName,' ',LastName)
     FROM dbo.[Clerk] WHERE IsDeleted<>1;
	 
     INSERT INTO @StaffTable(StaffId, StaffName)
     SELECT CONCAT(6,'_',CabDriverId),CONCAT(FirstName,' ',LastName)
     FROM dbo.[CabDriver] WHERE IsDeleted<>1;
     
SELECT * FROM @StaffTable ORDER BY StaffName ASC;

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
