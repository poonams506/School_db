-- =============================================
-- Author:    Poonam Bhalke
-- Create date: 08/04/2024
-- Description:  This stored procedure is used to get Survey Info
-- =============================================

CREATE PROCEDURE [dbo].[uspSurveyGridSelect](@RequestModel NVARCHAR(MAX),
@UserId INT)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SurveyTypeId SMALLINT = JSON_VALUE(@RequestModel, '$.surveyTypeTo');
        DECLARE @RefId SMALLINT = JSON_VALUE(@RequestModel, '$.refId');
		DECLARE @RoleId SMALLINT = JSON_VALUE(@RequestModel, '$.roleId');
        DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
        DECLARE @PageSize INT = JSON_VALUE(@RequestModel, '$.getListModel.length');
        DECLARE @PageNumber INT = JSON_VALUE(@RequestModel, '$.getListModel.start');
        DECLARE @SearchText NVARCHAR(150) = JSON_VALUE(@RequestModel, '$.getListModel.search.value');
        DECLARE @OrderBy INT = JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
        DECLARE @OrderBy_ASC_DESC NVARCHAR(20) = JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');
        DECLARE @SearchDate DATE;
        IF ISDATE(@SearchText) = 1
        BEGIN
            SET @SearchDate = CONVERT(DATE, @SearchText, 103);
        END

        IF(@SurveyTypeId = 1)
        BEGIN
           SET @RefId = @UserId
        END
        IF @SurveyTypeId = 1
          BEGIN
            SELECT COUNT(s.SurveyId)
            FROM dbo.Survey AS s
              LEFT JOIN dbo.[User] u ON s.createdBy = u.UserId
              LEFT JOIN dbo.[User] u_modified ON s.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(s.IsDeleted, 0) <> 1
                   AND s.CreatedBy =
			  CASE WHEN @RoleId > 2 THEN 
				@RefId 
			  ELSE
				s.CreatedBy
			  END
                AND s.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (s.Title LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 6 AND 'ClassTeacherId' LIKE '%' + @SearchText + '%')

                    OR CONVERT(NVARCHAR(10), s.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), s.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR s.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (s.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (s.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.ModifiedDate LIKE '%' + @SearchText + '%'
                )); 
          END
        ELSE IF @SurveyTypeId = 2
        BEGIN
             SELECT COUNT(s.SurveyId)
            FROM dbo.Survey AS s
           LEFT JOIN dbo.[User] u ON s.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON s.ModifiedBy = u_modified.UserId 
            INNER JOIN dbo.SurveyMapping sm ON sm.SurveyId = s.SurveyId
            WHERE
                ISNULL(s.IsDeleted, 0) <> 1
                  AND  CASE
				 WHEN @RoleId = 3 AND sm.TeacherId = @RefId THEN 1
				 WHEN @RoleId = 4 AND sm.ClerkId = @RefId THEN 1
                 WHEN @RoleId = 3 AND sm.ClassTeacherId = @RefId THEN 1
				 ELSE 0
			  END = 1
                AND s.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (s.Title LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 6 AND 'ClassTeacherId' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), s.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), s.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR s.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (s.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (s.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.ModifiedDate LIKE '%' + @SearchText + '%'
                )); 
        END
        

                                                      

        IF (@OrderBy_ASC_DESC = 'desc')
        BEGIN

           IF @SurveyTypeId = 1
             BEGIN
                 SELECT 
				 s.AcademicYearId,
                s.SurveyToType,
                CASE 
                    WHEN s.SurveyToType = 1 THEN 'Student'
                    WHEN s.SurveyToType = 2 THEN 'Class'
                    WHEN s.SurveyToType = 3 THEN 'Teacher'
                    WHEN s.SurveyToType = 4 THEN 'Clerk'
                    WHEN s.SurveyToType = 5 THEN 'Cab Driver'
                     WHEN s.SurveyToType = 6 THEN 'Class Teacher'
                END AS 'Survey To',
				s.SurveyId,
                s.Description AS 'SurveyDescription',
                s.EndDate,
                s.IsPublished,
                CASE 
                    WHEN s.IsPublished = 1 THEN 'Published'
                    WHEN s.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                s.StartDate,
                s.Title AS 'SurveyTitle',
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                s.CreatedDate,
                CASE 
                    WHEN s.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                s.ModifiedDate
            FROM dbo.Survey AS s
            LEFT JOIN dbo.[User] u ON s.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON s.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(s.IsDeleted, 0) <> 1
                   AND s.CreatedBy =
			  CASE WHEN @RoleId > 2 THEN 
				@RefId 
			  ELSE
				s.CreatedBy
			  END
                AND s.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (s.Title LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 6 AND 'ClassTeacherId' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), s.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), s.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR s.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (s.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (s.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
                CASE WHEN @OrderBy = 1 THEN s.Title END DESC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                        WHEN s.SurveyToType = 1 THEN 'Student'
                        WHEN s.SurveyToType = 2 THEN 'Class'
                        WHEN s.SurveyToType = 3 THEN 'Teacher'
                        WHEN s.SurveyToType = 4 THEN 'Clerk'
                        WHEN s.SurveyToType = 5 THEN 'Cab Driver'
                        WHEN s.SurveyToType = 6 THEN 'Class Teacher'
                    END
                END DESC,
				
                CASE WHEN @OrderBy = 2 THEN s.StartDate END DESC,
                CASE WHEN @OrderBy = 3 THEN s.EndDate END DESC,
                CASE WHEN @OrderBy = 4 THEN s.IsPublished END DESC,
                CASE WHEN @OrderBy = 5 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END DESC,
                CASE WHEN @OrderBy = 6 THEN s.CreatedDate END DESC,
                CASE WHEN @OrderBy = 7 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END DESC,
                CASE WHEN @OrderBy = 8 THEN s.ModifiedDate END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY
             END
           ELSE IF @SurveyTypeId = 2
            BEGIN
               SELECT 
				 s.AcademicYearId,
                s.SurveyToType,
                CASE 
                    WHEN s.SurveyToType = 1 THEN 'Student'
                    WHEN s.SurveyToType = 2 THEN 'Class'
                    WHEN s.SurveyToType = 3 THEN 'Teacher'
                    WHEN s.SurveyToType = 4 THEN 'Clerk'
                    WHEN s.SurveyToType = 5 THEN 'Cab Driver'
                     WHEN s.SurveyToType = 6 THEN 'Class Teacher'
                END AS 'Survey To',
				s.SurveyId,
                s.Description AS 'SurveyDescription',
                s.EndDate,
                s.IsPublished,
                CASE 
                    WHEN s.IsPublished = 1 THEN 'Published'
                    WHEN s.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                s.StartDate,
                s.Title AS 'SurveyTitle',
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                s.CreatedDate,
                CASE 
                    WHEN s.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                s.ModifiedDate
            FROM dbo.Survey AS s
            LEFT JOIN dbo.[User] u ON s.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON s.ModifiedBy = u_modified.UserId 
            INNER JOIN dbo.SurveyMapping sm ON sm.SurveyId = s.SurveyId
            WHERE
                ISNULL(s.IsDeleted, 0) <> 1
                  AND  CASE
				 WHEN @RoleId = 3 AND sm.TeacherId = @RefId THEN 1
				 WHEN @RoleId = 4 AND sm.ClerkId = @RefId THEN 1
				 WHEN @RoleId = 3 AND sm.ClassTeacherId = @RefId THEN 1
				 ELSE 0
			  END = 1
                AND s.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (s.Title LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 6 AND 'ClassTeacherId' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), s.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), s.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR s.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (s.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (s.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
                CASE WHEN @OrderBy = 1 THEN s.Title END DESC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                        WHEN s.SurveyToType = 1 THEN 'Student'
                        WHEN s.SurveyToType = 2 THEN 'Class'
                        WHEN s.SurveyToType = 3 THEN 'Teacher'
                        WHEN s.SurveyToType = 4 THEN 'Clerk'
                        WHEN s.SurveyToType = 5 THEN 'Cab Driver'
                        WHEN s.SurveyToType = 6 THEN 'Class Teacher'
                    END
                END DESC,
				
                CASE WHEN @OrderBy = 2 THEN s.StartDate END DESC,
                CASE WHEN @OrderBy = 3 THEN s.EndDate END DESC,
                CASE WHEN @OrderBy = 4 THEN s.IsPublished END DESC,
                CASE WHEN @OrderBy = 5 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END DESC,
                CASE WHEN @OrderBy = 6 THEN s.CreatedDate END DESC,
                CASE WHEN @OrderBy = 7 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END DESC,
                CASE WHEN @OrderBy = 8 THEN s.ModifiedDate END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY
            END

            
        END
        ELSE
        BEGIN
         
            IF @SurveyTypeId = 1
             BEGIN
             SELECT
			 s.AcademicYearId,
			 s.SurveyId,
			 s.SurveyToType,
                CASE 
                    WHEN s.SurveyToType = 1 THEN 'Student'
                    WHEN s.SurveyToType = 2 THEN 'Class'
                    WHEN s.SurveyToType = 3 THEN 'Teacher'
                    WHEN s.SurveyToType = 4 THEN 'Clerk'
                    WHEN s.SurveyToType = 5 THEN 'Cab Driver'
                    WHEN s.SurveyToType = 6 THEN 'Class Teacher'
                END AS 'Survey To',
                s.EndDate,
                s.IsPublished,
                s.IsPublished,
                CASE 
                    WHEN s.IsPublished = 1 THEN 'Published'
                    WHEN s.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                s.StartDate,
                s.Title AS 'SurveyTitle',
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                s.CreatedDate,
                CASE 
                    WHEN s.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                s.ModifiedDate
            FROM dbo.Survey AS s
            LEFT JOIN dbo.[User] u ON s.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON s.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(s.IsDeleted, 0) <> 1
                   AND s.CreatedBy =
			  CASE WHEN @RoleId > 2 THEN 
				@RefId 
			  ELSE
				s.CreatedBy
			  END
                AND s.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (s.Title LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 6 AND 'ClassTeacherId' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), s.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), s.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR s.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
				   OR (
                        LEN(@SearchText) > 0 AND (
                          (s.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (s.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
                CASE WHEN @OrderBy = 1 THEN s.Title END ASC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                    WHEN s.SurveyToType = 1 THEN 'Student'
                    WHEN s.SurveyToType = 2 THEN 'Class'
                    WHEN s.SurveyToType = 3 THEN 'Teacher'
                    WHEN s.SurveyToType = 4 THEN 'Clerk'
                    WHEN s.SurveyToType = 5 THEN 'Cab Driver'
                    WHEN s.SurveyToType = 6 THEN 'Class Teacher'
                    END
                    END ASC,
                CASE WHEN @OrderBy = 2 THEN s.StartDate END ASC,
                CASE WHEN @OrderBy = 3 THEN s.EndDate END ASC,
                CASE WHEN @OrderBy = 4 THEN s.IsPublished END ASC,
                CASE WHEN @OrderBy = 5 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END ASC,
                CASE WHEN @OrderBy = 6 THEN s.CreatedDate END ASC,
                CASE WHEN @OrderBy = 7 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END ASC,
                CASE WHEN @OrderBy = 8 THEN s.ModifiedDate END ASC

            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
             END
           ELSE IF @SurveyTypeId = 2
            BEGIN
            SELECT
			s.AcademicYearId,
			s.SurveyId,
			 s.SurveyToType,
                CASE 
                    WHEN s.SurveyToType = 1 THEN 'Student'
                    WHEN s.SurveyToType = 2 THEN 'Class'
                    WHEN s.SurveyToType = 3 THEN 'Teacher'
                    WHEN s.SurveyToType = 4 THEN 'Clerk'
                    WHEN s.SurveyToType = 5 THEN 'Cab Driver'
                    WHEN s.SurveyToType = 6 THEN 'Class Teacher'
                END AS 'Survey To',
                s.EndDate,
                s.IsPublished,
                s.IsPublished,
                CASE 
                    WHEN s.IsPublished = 1 THEN 'Published'
                    WHEN s.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                s.StartDate,
                s.Title AS 'SurveyTitle',
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                s.CreatedDate,
                CASE 
                    WHEN s.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                s.ModifiedDate
            FROM dbo.Survey AS s
            LEFT JOIN dbo.[User] u ON s.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON s.ModifiedBy = u_modified.UserId 
            INNER JOIN dbo.SurveyMapping sm ON sm.SurveyId = s.SurveyId
            WHERE
                ISNULL(s.IsDeleted, 0) <> 1
                AND s.AcademicYearId = @AcademicYearId
                 AND  CASE
				 WHEN @RoleId = 3 AND sm.TeacherId = @RefId THEN 1
				 WHEN @RoleId = 4 AND sm.ClerkId = @RefId THEN 1
				 WHEN @RoleId = 3 AND sm.ClassTeacherId = @RefId THEN 1
				 ELSE 0
			  END = 1
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (s.Title LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR (s.SurveyToType = 6 AND 'ClassTeacherId' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), s.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), s.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR s.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
				   OR (
                        LEN(@SearchText) > 0 AND (
                          (s.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (s.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), s.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR s.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
               -- h.CreatedDate DESC, -- Newly added homework on top
                CASE WHEN @OrderBy = 1 THEN s.Title END ASC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                        WHEN s.SurveyToType = 1 THEN 'Student'
                        WHEN s.SurveyToType = 2 THEN 'Class'
                        WHEN s.SurveyToType = 3 THEN 'Teacher'
                        WHEN s.SurveyToType = 4 THEN 'Clerk'
                        WHEN s.SurveyToType = 5 THEN 'Cab Driver'
                        WHEN s.SurveyToType = 6 THEN 'Class Teacher'

                    END
                    END ASC,
                CASE WHEN @OrderBy = 2 THEN s.StartDate END ASC,
                CASE WHEN @OrderBy = 3 THEN s.EndDate END ASC,
                CASE WHEN @OrderBy = 4 THEN s.IsPublished END ASC,
                CASE WHEN @OrderBy = 5 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END ASC,
                CASE WHEN @OrderBy = 6 THEN s.CreatedDate END ASC,
                CASE WHEN @OrderBy = 7 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END ASC,
                CASE WHEN @OrderBy = 8 THEN s.ModifiedDate END ASC

            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
            END


            
        END
    END TRY
    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
        EXEC dbo.uspExceptionLogInsert @ErrorLine,
                                        @ErrorMessage,
                                        @ErrorNumber,
                                        @ErrorProcedure,
                                        @ErrorSeverity,
                                        @ErrorState;
    END CATCH 
END

