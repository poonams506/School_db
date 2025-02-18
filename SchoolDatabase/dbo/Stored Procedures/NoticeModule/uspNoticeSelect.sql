-- =============================================
-- Author:    Poonam  Bhalke
-- Create date: 28/08/2023
-- Description:  This stored procedure is used to get Notice info detail by Select
-- =============================================
CREATE PROC uspNoticeSelect 
(
    @NoticeId BIGINT
)
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
DECLARE @AcademicYearId INT;
(SELECT @AcademicYearId = h.AcademicYearId
FROM 
    dbo.Notice AS h
WHERE
    h.NoticeId = @NoticeId AND
    h.IsDeleted<>1 )

SELECT 
    h.NoticeId,
    h.IsImportant,
    h.NoticeToType,
    h.Title AS NoticeTitle,
    h.[Description] AS NoticeDescription,
    h.StartDate,
    h.EndDate,
    h.IsPublished
FROM 
    dbo.Notice AS h
WHERE
    h.NoticeId = @NoticeId AND
    h.IsDeleted<>1 

SELECT 
    hw.NoticeId,
	hw.FileName,
	hw.FileType
FROM
    dbo.NoticeDetails AS hw
WHERE
    hw.NoticeId = @NoticeId AND
    hw.IsDeleted<>1 AND hw.FileType=1;

    SELECT 
    nmd.NoticeId,
	nmd.ContentUrl

FROM
    dbo.NoticeMediaDetails AS nmd
WHERE
    nmd.NoticeId = @NoticeId AND
    nmd.IsDeleted<>1 

    SELECT 
        nm.NoticeId,
        nm.StudentId,
        sgdm.SchoolGradeDivisionMatrixId AS ClassId,
        nm.TeacherId, 
        nm.ClerkId,
        nm.CabDriverId
    FROM 
        dbo.NoticeMapping nm
    LEFT JOIN 
      dbo.SchoolGradeDivisionMatrix sgdm ON  nm.GradeId=sgdm.GradeId AND nm.DivisionId=sgdm.DivisionId AND sgdm.AcademicYearId = @AcademicYearId
    WHERE 
        nm.NoticeId=@NoticeId  
        AND (sgdm.IsDeleted <> 1 OR sgdm.SchoolGradeDivisionMatrixId IS NULL);

 END 
 TRY 
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
    END CATCH;
END;

