-- =============================================
-- Author:    Prathamesh Ghue
-- Create date: 25/08/2023
-- Description:  This stored procedure is used to get StudentAttendance info
-- =============================================
CREATE PROC uspStudentAttendanceGridSelect (
@AcademicYearId SMALLINT,
@GradeId SMALLINT,
@DivisionId SMALLINT,
@AttendanceDate DATETIME
)
AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY
  SELECT   s.StudentId , 
           sgdm.RollNumber,
           CONCAT(s.FirstName,' ',s.MiddleName,' ' , s.LastName) as 'FullName',
           ISNULL(sa.StatusId,0) AS StatusId, 
           ISNULL(sa.Reason,'') AS Reason
  FROM Student s
     INNER JOIN StudentGradeDivisionMapping sgdm ON s.StudentId = sgdm.StudentId   
     LEFT JOIN StudentAttendance sa ON sa.StudentId=s.StudentId 
     AND sa.AcademicYearId=@AcademicYearId 
     AND sa.AttendanceDateTime = @AttendanceDate
     AND sa.GradeId = @GradeId
     AND sa.DivisionId = @DivisionId
  WHERE 
      sgdm.AcademicYearId=@AcademicYearId
      AND sgdm.GradeId=@GradeId
      AND sgdm.DivisionId=@DivisionId
      AND s.IsDeleted <> 1
      AND s.IsArchive <> 1
  ORDER BY CAST(sgdm.RollNumber as INT) ASC
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