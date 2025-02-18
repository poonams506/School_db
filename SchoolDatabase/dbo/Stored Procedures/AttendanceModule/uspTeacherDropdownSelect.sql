-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 21/09/2023
-- Description:  This stored procedure is used to get Teacher dropdown
-- =============================================
CREATE PROC uspTeacherDropdownSelect AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT 
  TeacherId,
  CONCAT(FirstName,' ',MiddleName,' ',LastName) AS FullName
FROM 
  dbo.Teacher 
WHERE 
  IsDeleted <> 1
  ORDER BY FullName;
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
@ErrorState END CATCH End
