-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 2/01/2024
-- Description:  This stored procedure is used to get Homework info detail by Select
-- =============================================
CREATE PROC dbo.uspHomeworkParentAppSelect(
@Month INT, 
@Year INT,
@AcademicYearId SMALLINT,
@StudentId INT

)
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY

DECLARE @GradeId SMALLINT,@DivisionId SMALLINT;

SELECT @GradeId=sgd.GradeId,@DivisionId=sgd.DivisionId
	FROM dbo.StudentGradeDivisionMapping sgd
    WHERE sgd.StudentId=@StudentId AND sgd.AcademicYearId=@AcademicYearId AND sgd.IsDeleted <> 1;

SELECT TOP 50
    h.AcademicYearId,
    h.HomeWorkId,
    h.GradeId,
    h.DivisionId,
    h.SubjectId,
    s.SubjectName,
    h.Title AS HomeworkTitle,
    h.[Description] AS HomeworkDescription,
    h.StartDate,
    h.EndDate,
    h.IsPublished
FROM 
    dbo.HomeWork AS h
    INNER JOIN SubjectMaster s ON h.SubjectId = s.SubjectMasterId
WHERE
    h.AcademicYearId = @AcademicYearId AND 
    h.GradeId = @GradeId AND
    h.DivisionId = @DivisionId AND
    h.IsDeleted<>1 AND h.isPublished=1 AND
    s.IsDeleted<>1
	AND MONTH(h.StartDate) = @Month AND YEAR(h.StartDate) = @Year  
ORDER BY h.StartDate DESC;

	SELECT 
    hw.HomeWorkId,
	hw.FileName,
	hw.FileType
FROM 
    dbo.HomeWork AS h
	INNER JOIN dbo.HomeWorkDetails AS hw ON h.HomeWorkId = hw.HomeWorkId
	WHERE
    h.AcademicYearId = @AcademicYearId AND 
    h.GradeId = @GradeId AND
    h.DivisionId = @DivisionId AND
    h.IsDeleted<>1 AND h.isPublished=1
	AND MONTH(h.StartDate) = @Month AND YEAR(h.StartDate) = @Year  


    SELECT 
        hmd.HomeWorkId,
        hmd.ContentUrl
FROM 
    dbo.HomeWork AS h
    INNER JOIN dbo.HomeworkMediaDetail AS hmd ON h.HomeWorkId = hmd.HomeWorkId
    WHERE 
    h.AcademicYearId = @AcademicYearId AND 
    h.GradeId = @GradeId AND 
    h.DivisionId = @DivisionId AND 
    h.IsDeleted <> 1 AND 
    h.IsPublished = 1
	AND MONTH(h.StartDate) = @Month AND YEAR(h.StartDate) = @Year  


 END 
 TRY 
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
@ErrorState 

END CATCH

END
GO
