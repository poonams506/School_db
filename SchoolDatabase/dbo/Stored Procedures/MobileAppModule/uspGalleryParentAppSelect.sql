-- =============================================
-- Author:    Poonam Bhalke
-- Create date: 23/07/2024
-- Description:  This stored procedure is used to get gallery info detail for student
-- =============================================
CREATE PROC [dbo].[uspGalleryParentAppSelect](
@AcademicYearId SMALLINT,
@StudentId INT,
@FromDate DATE,
@TillDate DATE
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
    
    n.GalleryId,
    n.GalleryToType,
    n.Title AS GalleryTitle,
    n.Description,
    n.StartDate,
    n.IsPublished,
    np.StudentId,
    np.GradeId,
    np.DivisionId,
	r.RoleId,
	r.RoleKey,
	r.[Name] AS RoleName,
	n.CreatedDate
FROM 
      dbo.Gallery AS n
      INNER JOIN dbo.GalleryMapping AS np ON n.GalleryId = np.GalleryId
	  LEFT JOIN dbo.UserRole ur ON ur.UserId=n.CreatedBy
	  LEFT JOIN dbo.[Role] r ON r.RoleId=ur.RoleId
WHERE
    n.AcademicYearId = @AcademicYearId AND 
    n.StartDate BETWEEN @FromDate AND @TillDate AND
    ((np.GradeId =@GradeId AND np.DivisionId =@DivisionId) OR  np.StudentId = @StudentId) AND r.RoleId in (1,2,3,4,6,7) AND
    n.IsDeleted<>1 AND n.IsPublished=1;

 SELECT 
    n.GalleryId,
    nd.FileName,
    nd.FileType
FROM 
      dbo.Gallery AS n
      INNER JOIN dbo.GalleryMapping AS np ON n.GalleryId = np.GalleryId
      INNER JOIN dbo.GalleryDetails AS nd ON n.GalleryId = nd.GalleryId
WHERE
    n.AcademicYearId = @AcademicYearId AND 
    n.StartDate BETWEEN @FromDate AND @TillDate AND
    ((np.GradeId =@GradeId AND np.DivisionId =@DivisionId) OR  np.StudentId = @StudentId) AND
    n.IsDeleted<>1 AND n.IsPublished=1;

   -- Fetch gallery media details
        SELECT 
            n.GalleryId,
            nmd.ContentUrl
        FROM
            dbo.Gallery AS n
            INNER JOIN dbo.GalleryMapping AS np ON n.GalleryId = np.GalleryId
            INNER JOIN dbo.GalleryMediaDetails AS nmd ON n.GalleryId = nmd.GalleryId
        WHERE
            n.AcademicYearId = @AcademicYearId 
            AND n.StartDate BETWEEN @FromDate AND @TillDate 
            AND ((np.GradeId = @GradeId AND np.DivisionId = @DivisionId) OR np.StudentId = @StudentId) 
            AND n.IsDeleted <> 1 
            AND n.IsPublished = 1 
            AND nmd.IsDeleted <> 1;

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

