-- =============================================
-- Author:    Deepak W
-- Create date: 22/03/2024
-- Description:  get notices list for teacher app
-- =============================================
CREATE PROC uspNoticesTeacherAppSelect(@AcademicYearId INT,@NoticeTypeId TINYINT, @RefId INT, @Month INT, @Year INT)
AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

          IF @NoticeTypeId = 1
          BEGIN
          SELECT h.NoticeId,
			 h.NoticeToType,
               CASE 
                    WHEN h.NoticeToType = 1 THEN 'Student'
                    WHEN h.NoticeToType = 2 THEN 'Class'
                    WHEN h.NoticeToType = 3 THEN 'Teacher'
                    WHEN h.NoticeToType = 4 THEN 'Clerk'
                    WHEN h.NoticeToType = 5 THEN 'Cab Driver'
                END AS 'NoticeTo',
                h.EndDate,
                h.IsImportant,
                h.IsPublished,
                CASE 
                    WHEN h.IsPublished = 1 THEN 'Published'
                    WHEN h.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                h.StartDate,
                h.Title AS NoticeTitle,
                u.Fname + '' + u.Mname + ' ' + u.Lname AS 'CreatedBy',
                h.CreatedDate,
                CASE 
                    WHEN h.ModifiedDate IS NULL THEN ''
                    ELSE ISNULL(u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname, '')
                END AS 'ModifiedBy',
                h.ModifiedDate
            FROM dbo.Notice AS h
            LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(h.IsDeleted, 0) <> 1
                AND h.AcademicYearId = @AcademicYearId
                AND h.CreatedBy = @RefId
				AND MONTH(h.StartDate) = @Month AND YEAR(h.StartDate) = @Year  
            ORDER BY
               h.CreatedDate DESC
            END
            ELSE IF @NoticeTypeId = 2
            BEGIN
              SELECT h.NoticeId,
			     h.NoticeToType,
                    CASE 
                        WHEN h.NoticeToType = 1 THEN 'Student'
                        WHEN h.NoticeToType = 2 THEN 'Class'
                        WHEN h.NoticeToType = 3 THEN 'Teacher'
                        WHEN h.NoticeToType = 4 THEN 'Clerk'
                        WHEN h.NoticeToType = 5 THEN 'Cab Driver'
                    END AS 'NoticeTo',
                    h.EndDate,
                    h.IsImportant,
                    h.IsPublished,
                    CASE 
                        WHEN h.IsPublished = 1 THEN 'Published'
                        WHEN h.IsPublished = 0 THEN 'Unpublished'
                    END AS 'Status',
                    h.StartDate,
                    h.Title AS NoticeTitle,
                    u.Fname + '' + u.Mname + ' ' + u.Lname AS 'CreatedBy',
                    h.CreatedDate,
                    CASE 
                        WHEN h.ModifiedDate IS NULL THEN ''
                        ELSE ISNULL(u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname, '')
                    END AS 'ModifiedBy',
                    h.ModifiedDate
                FROM dbo.Notice AS h
                LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
                LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId
                INNER JOIN dbo.NoticeMapping m ON m.NoticeId = h.NoticeId
                WHERE
                    ISNULL(h.IsDeleted, 0) <> 1
                    AND h.AcademicYearId = @AcademicYearId
                    AND m.TeacherId = @RefId
					 AND MONTH(h.StartDate) = @Month AND YEAR(h.StartDate) = @Year  
                ORDER BY
                   h.CreatedDate DESC
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
