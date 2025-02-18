-- =============================================
-- Author:        Saurabh Walunj
-- Create date:   25/07/2024
-- Description:   This stored procedure is used to get Exam Object info detail by Select
-- =============================================
CREATE PROC [dbo].[uspExamObjectSelect] 
(
    @ExamMasterId BIGINT,
	@SubjectMasterId BIGINT,
    @AcademicYearId INT
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY

	     SELECT 
           eo.ExamObjectId,
		   eo.AcademicYearId,
           em.ExamMasterId,
		   em.ExamName AS Name,
           sm.SubjectMasterId,
		   sm.SubjectName
        FROM CBSE_ExamObject  AS eo
		INNER JOIN CBSE_ExamMaster AS em ON eo.ExamMasterId = em.ExamMasterId
		INNER JOIN SubjectMaster AS sm ON eo.SubjectMasterId = sm.SubjectMasterId

        WHERE 
		eo.ExamMasterId = @ExamMasterId
		AND eo.SubjectMasterId = @SubjectMasterId
		AND eo.AcademicYearId = @AcademicYearId
		AND eo.IsDeleted <> 1;


         SELECT 
           eo.ExamObjectId,
		   eo.AcademicYearId,
           em.ExamMasterId,
		   em.ExamName AS Name,
           sm.SubjectMasterId,
		   sm.SubjectName,
		   eo.ObjectName,
		   eo.OutOfMarks,
		   eo.IsPublished


        FROM CBSE_ExamObject  AS eo
		INNER JOIN CBSE_ExamMaster AS em ON eo.ExamMasterId = em.ExamMasterId
		INNER JOIN SubjectMaster AS sm ON eo.SubjectMasterId = sm.SubjectMasterId

        WHERE 
		eo.ExamMasterId = @ExamMasterId 
		AND eo.SubjectMasterId = @SubjectMasterId
        AND eo.AcademicYearId = @AcademicYearId
		AND eo.IsDeleted <> 1;

    END TRY 
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();

        EXEC uspExceptionLogInsert 
            @ErrorLine, 
            @ErrorMessage, 
            @ErrorNumber, 
            @ErrorProcedure, 
            @ErrorSeverity, 
            @ErrorState;
    END CATCH
END