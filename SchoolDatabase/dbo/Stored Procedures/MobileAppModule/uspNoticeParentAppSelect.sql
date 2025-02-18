-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 2/01/2024
-- Description:  This stored procedure is used to get Notice info detail for student
-- =============================================
CREATE PROC [dbo].[uspNoticeParentAppSelect](
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

SELECT 
    TOP 30
    n.NoticeId,
    n.IsImportant,
    n.NoticeToType,
    n.Title AS NoticeTitle,
    n.[Description] AS NoticeDescription,
    n.StartDate,
    n.EndDate,
    n.IsPublished,
    np.StudentId,
    np.GradeId,
    np.DivisionId,
	r.RoleId,
	r.RoleKey,
	r.[Name] AS RoleName,
	n.CreatedDate
FROM 
      dbo.Notice AS n
      INNER JOIN dbo.NoticeMapping AS np ON n.NoticeId = np.NoticeId
	  LEFT JOIN dbo.UserRole ur ON ur.UserId=n.CreatedBy
	  LEFT JOIN dbo.[Role] r ON r.RoleId=ur.RoleId
WHERE
    n.AcademicYearId = @AcademicYearId AND 
    ((np.GradeId =@GradeId AND np.DivisionId =@DivisionId) OR  np.StudentId = @StudentId) AND r.RoleId in (1,2,3,4,6,7) AND
    n.IsDeleted<>1 AND n.IsPublished=1
	AND MONTH(n.StartDate) = @Month AND YEAR(n.StartDate) = @Year  
ORDER BY StartDate DESC;

 SELECT 
    n.NoticeId,
    nd.FileName,
    nd.FileType
FROM 
      dbo.Notice AS n
      INNER JOIN dbo.NoticeMapping AS np ON n.NoticeId = np.NoticeId
      INNER JOIN dbo.NoticeDetails AS nd ON n.NoticeId = nd.NoticeId
WHERE
    n.AcademicYearId = @AcademicYearId AND 
    ((np.GradeId =@GradeId AND np.DivisionId =@DivisionId) OR  np.StudentId = @StudentId) AND
    n.IsDeleted<>1 AND n.IsPublished=1
	AND MONTH(n.StartDate) = @Month AND YEAR(n.StartDate) = @Year  

   -- Fetch notice media details
        SELECT 
            n.NoticeId,
            nmd.ContentUrl
        FROM
            dbo.Notice AS n
            INNER JOIN dbo.NoticeMapping AS np ON n.NoticeId = np.NoticeId
            INNER JOIN dbo.NoticeMediaDetails AS nmd ON n.NoticeId = nmd.NoticeId
        WHERE
            n.AcademicYearId = @AcademicYearId 
            AND ((np.GradeId = @GradeId AND np.DivisionId = @DivisionId) OR np.StudentId = @StudentId) 
            AND n.IsDeleted <> 1 
            AND n.IsPublished = 1 
            AND nmd.IsDeleted <> 1
			AND MONTH(n.StartDate) = @Month AND YEAR(n.StartDate) = @Year  

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
