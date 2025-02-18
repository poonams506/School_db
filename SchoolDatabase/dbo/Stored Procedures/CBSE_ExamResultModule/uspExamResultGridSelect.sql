-- =============================================
-- Author:    Prathamesh Ghue
-- Create date: 25/08/2023
-- Description:  This stored procedure is used to get StudentAttendance info
-- =============================================
CREATE PROC uspExamResultGridSelect  (
@AcademicYearId SMALLINT,
@GradeId SMALLINT,
@DivisionId SMALLINT,
@ExamMasterId SMALLINT,
@SubjectMasterId INT
)
AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY
SELECT 
sgdm.RollNumber,
s.StudentId,
CONCAT(s.FirstName,' ',s.MiddleName,' ',s.LastName)AS 'StudentName'
FROM Student s
INNER JOIN StudentGradeDivisionMapping sgdm ON s.StudentId = sgdm.StudentId   
WHERE  sgdm.AcademicYearId=@AcademicYearId
 AND sgdm.GradeId=@GradeId
 AND sgdm.DivisionId=@DivisionId
 AND s.IsDeleted <> 1
 AND s.IsArchive <> 1 ; 


SELECT 
DISTINCT
eo.ExamObjectId,
eo.ObjectName,
eo.OutOfMarks,
er.ActualMarks,
er.StudentId
FROM CBSE_ExamObject eo
LEFT JOIN CBSE_ExamResult er  ON eo.ExamObjectId = er.ExamObjectId and er.AcademicYearId=@AcademicYearId 
INNER JOIN CBSE_ClassExamMapping cem ON eo.ExamMasterId = cem.ExamMasterId  AND cem.GradeId=@GradeId AND 
cem.DivisionId=@DivisionId AND cem.AcademicYearId=@AcademicYearId
WHERE 
ISNULL(er.IsDeleted, 0) <> 1 AND 
ISNULL(eo.IsDeleted, 0) <> 1 AND 
ISNULL(cem.IsDeleted, 0) <> 1 AND
eo.AcademicYearId=@AcademicYearId AND 
eo.ExamMasterId=@ExamMasterId AND
eo.SubjectMasterId=@SubjectMasterId
 
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