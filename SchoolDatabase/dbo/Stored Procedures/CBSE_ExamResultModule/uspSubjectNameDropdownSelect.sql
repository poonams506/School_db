-- =============================================
-- Author:    Prathamesh Ghule
-- Create date: 27/08/2024
-- Description:  This stored procedure is used to get Subject Name dropdown from  ExamMasterId
-- =============================================
CREATE PROC uspSubjectNameDropdownSelect
(
@AcademicYearId int = null,
@ExamMasterId int=null
)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT  DISTINCT
em.SubjectMasterId,
    sm.SubjectName
FROM 
    CBSE_ExamObject AS em
INNER JOIN 
    CBSE_ExamMaster AS ems ON em.ExamMasterId = ems.ExamMasterId
INNER JOIN 
    SubjectMaster AS sm ON em.SubjectMasterId = sm.SubjectMasterId
WHERE 
    em.AcademicYearId=@AcademicYearId AND 
    em.ExamMasterId = @ExamMasterId
    AND em.IsDeleted <> 1;

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