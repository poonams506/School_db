-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 30/12/2023
-- Description:  This stored procedure is used to get teacher dropdown list
-- =============================================
CREATE PROC uspTeacherDropdownMasterSelect(@AcademicYearId INT)
AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 


SELECT 
  t.TeacherId AS TeacherId,
  CONCAT(t.FirstName,' ',t.MiddleName, ' ' , t.LastName) AS TeacherName,
  ts.SubjectMasterId AS SubjectMasterId
  FROM 
  dbo.Teacher t JOIN
  dbo.TeacherSubjectMapping ts ON t.TeacherId=ts.TeacherId 
WHERE 
 t.IsDeleted <> 1 AND ts.IsDeleted<>1 AND
 ts.AcademicYearId=@AcademicYearId
 ORDER BY 
  CONCAT(t.FirstName,' ',t.MiddleName, ' ' , t.LastName) ASC
END TRY 

BEGIN CATCH 

DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
