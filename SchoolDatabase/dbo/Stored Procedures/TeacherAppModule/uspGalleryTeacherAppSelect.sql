-- =============================================
-- Author:    Poonam Bhalke
-- Create date: 18/07/2024
-- Description:  Get Gallery list for teacher app
-- =============================================
CREATE PROC uspGalleryTeacherAppSelect(@AcademicYearId INT,@GalleryTypeId TINYINT, @RefId INT)
AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

          IF @GalleryTypeId = 1
          BEGIN
          SELECT g.GalleryId,
			 g.GalleryToType,
               CASE 
                    WHEN g.GalleryToType = 1 THEN 'Student'
                    WHEN g.GalleryToType = 2 THEN 'Class'
                    WHEN g.GalleryToType = 3 THEN 'Teacher'
                    WHEN g.GalleryToType = 4 THEN 'Clerk'
                    WHEN g.GalleryToType = 5 THEN 'Cab Driver'
                END AS 'GalleryTo',
                g.IsPublished,
                CASE 
                    WHEN g.IsPublished = 1 THEN 'Published'
                    WHEN g.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                g.StartDate,
                g.Title AS GalleryTitle,
                u.Fname + '' + u.Mname + ' ' + u.Lname AS 'CreatedBy',
                g.CreatedDate,
                CASE 
                    WHEN g.ModifiedDate IS NULL THEN ''
                    ELSE ISNULL(u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname, '')
                END AS 'ModifiedBy',
                g.ModifiedDate
            FROM dbo.Gallery AS g
            LEFT JOIN dbo.[User] u ON g.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON g.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(g.IsDeleted, 0) <> 1
                AND g.AcademicYearId = @AcademicYearId
                AND g.CreatedBy = @RefId
            ORDER BY
               g.CreatedDate DESC
            END
            ELSE IF @GalleryTypeId = 2
            BEGIN
              SELECT g.GalleryId,
			     g.GalleryToType,
                    CASE 
                        WHEN g.GalleryToType = 1 THEN 'Student'
                        WHEN g.GalleryToType = 2 THEN 'Class'
                        WHEN g.GalleryToType = 3 THEN 'Teacher'
                        WHEN g.GalleryToType = 4 THEN 'Clerk'
                        WHEN g.GalleryToType = 5 THEN 'Cab Driver'
                    END AS 'GalleryTo',
                    g.IsPublished,
                    CASE 
                        WHEN g.IsPublished = 1 THEN 'Published'
                        WHEN g.IsPublished = 0 THEN 'Unpublished'
                    END AS 'Status',
                    g.StartDate,
                    g.Title AS GalleryTitle,
                    u.Fname + '' + u.Mname + ' ' + u.Lname AS 'CreatedBy',
                    g.CreatedDate,
                    CASE 
                        WHEN g.ModifiedDate IS NULL THEN ''
                        ELSE ISNULL(u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname, '')
                    END AS 'ModifiedBy',
                    g.ModifiedDate
                FROM dbo.Gallery AS g
                LEFT JOIN dbo.[User] u ON g.createdBy = u.UserId
                LEFT JOIN dbo.[User] u_modified ON g.ModifiedBy = u_modified.UserId
                INNER JOIN dbo.GalleryMapping m ON m.GalleryId = g.GalleryId
                WHERE
                    ISNULL(g.IsDeleted, 0) <> 1
                    AND g.AcademicYearId = @AcademicYearId
                    AND m.TeacherId = @RefId
                ORDER BY
                   g.CreatedDate DESC
            END

 END 

 TRY 
 BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();

DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
DECLARE @ErrorState INT = ERROR_STATE();
DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();
DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
EXEC uspExceptionLogInsert @ErrorLine, 
@ErrorMessage, 
@ErrorProcedure, 
@ErrorSeverity, 
@ErrorState END CATCH END

