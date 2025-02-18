-- =============================================
-- Author:    Saurabh Walunj
-- Create date: 05/07/2024
-- Description:  This stored procedure is used to get Gallery info
-- =============================================
CREATE PROCEDURE uspGalleryGridSelect(@RequestModel NVARCHAR(MAX),
@UserId INT)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @GalleryTypeId SMALLINT = JSON_VALUE(@RequestModel, '$.galleryTypeTo');
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

        IF(@GalleryTypeId = 1)
        BEGIN
           SET @RefId = @UserId
        END
        IF @GalleryTypeId = 1
          BEGIN
            SELECT COUNT(g.GalleryId)
            FROM dbo.Gallery AS g
           LEFT JOIN dbo.[User] u ON g.CreatedBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON g.ModifiedBy = u_modified.UserId 
            --INNER JOIN dbo.NoticeMapping m ON m.NoticeId = h.NoticeId
            WHERE
                ISNULL(g.IsDeleted, 0) <> 1
                   AND g.CreatedBy =
			  CASE WHEN @RoleId > 2 THEN 
				@RefId 
			  ELSE
				g.CreatedBy
			  END
                AND g.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (g.Title LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), g.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    --OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (g.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (g.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.ModifiedDate LIKE '%' + @SearchText + '%'
                )); 
          END
        ELSE IF @GalleryTypeId = 2
        BEGIN
             SELECT COUNT(g.GalleryId)
            FROM dbo.Gallery AS g
           LEFT JOIN dbo.[User] u ON g.CreatedBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON g.ModifiedBy = u_modified.UserId 
            INNER JOIN dbo.GalleryMapping gm ON gm.GalleryId = g.GalleryId
            WHERE
                ISNULL(g.IsDeleted, 0) <> 1
                  AND  CASE
				 WHEN @RoleId = 3 AND gm.TeacherId = @RefId THEN 1
				 WHEN @RoleId = 4 AND gm.ClerkId = @RefId THEN 1
				 ELSE 0
			  END = 1
                AND g.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (g.Title LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), g.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    --OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (g.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (g.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.ModifiedDate LIKE '%' + @SearchText + '%'
                )); 
        END
        

                                                      

        IF (@OrderBy_ASC_DESC = 'desc')
        BEGIN

           IF @GalleryTypeId = 1
             BEGIN
                 SELECT 
                g.GalleryToType,
                CASE 
                    WHEN g.GalleryToType = 1 THEN 'Student'
                    WHEN g.GalleryToType = 2 THEN 'Class'
                    WHEN g.GalleryToType = 3 THEN 'Teacher'
                    WHEN g.GalleryToType = 4 THEN 'Clerk'
                    WHEN g.GalleryToType = 5 THEN 'Cab Driver'
                END AS 'Gallery To',
				g.GalleryId,
                g.Description,
                g.IsPublished,
                CASE 
                    WHEN g.IsPublished = 1 THEN 'Published'
                    WHEN g.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                g.StartDate,
                g.Title AS GalleryTitle,
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                g.CreatedDate,
                CASE 
                    WHEN g.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                g.ModifiedDate
            FROM dbo.Gallery AS g
            LEFT JOIN dbo.[User] u ON g.CreatedBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON g.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(g.IsDeleted, 0) <> 1
                   AND g.CreatedBy =
			  CASE WHEN @RoleId > 2 THEN 
				@RefId 
			  ELSE
				g.CreatedBy
			  END
                AND g.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (g.Title LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), g.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    --OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (g.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (g.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
                CASE WHEN @OrderBy = 1 THEN g.Title END DESC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                        WHEN g.GalleryToType = 1 THEN 'Student'
                        WHEN g.GalleryToType = 2 THEN 'Class'
                        WHEN g.GalleryToType = 3 THEN 'Teacher'
                        WHEN g.GalleryToType = 4 THEN 'Clerk'
                        WHEN g.GalleryToType = 5 THEN 'Cab Driver'
                    END
                END DESC,
                CASE WHEN @OrderBy = 2 THEN g.StartDate END DESC,
               -- CASE WHEN @OrderBy = 3 THEN h.EndDate END DESC,
                CASE WHEN @OrderBy = 3 THEN g.IsPublished END DESC,
                CASE WHEN @OrderBy = 4 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END DESC,
                CASE WHEN @OrderBy = 5 THEN g.CreatedDate END DESC,
                CASE WHEN @OrderBy = 6 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END DESC,
                CASE WHEN @OrderBy = 7 THEN g.ModifiedDate END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY
             END
           ELSE IF @GalleryTypeId = 2
            BEGIN
               SELECT 
                g.GalleryToType,
                CASE 
                    WHEN g.GalleryToType = 1 THEN 'Student'
                    WHEN g.GalleryToType = 2 THEN 'Class'
                    WHEN g.GalleryToType = 3 THEN 'Teacher'
                    WHEN g.GalleryToType = 4 THEN 'Clerk'
                    WHEN g.GalleryToType = 5 THEN 'Cab Driver'
                END AS 'Gallery To',
				g.GalleryId,
                g.Description,
                g.IsPublished,
                CASE 
                    WHEN g.IsPublished = 1 THEN 'Published'
                    WHEN g.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                g.StartDate,
                g.Title AS GalleryTitle,
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                g.CreatedDate,
                CASE 
                    WHEN g.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                g.ModifiedDate
            FROM dbo.Gallery AS g
            LEFT JOIN dbo.[User] u ON g.CreatedBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON g.ModifiedBy = u_modified.UserId 
            INNER JOIN dbo.GalleryMapping gm ON gm.GalleryId = g.GalleryId
            WHERE
                ISNULL(g.IsDeleted, 0) <> 1
                  AND  CASE
				 WHEN @RoleId = 3 AND gm.TeacherId = @RefId THEN 1
				 WHEN @RoleId = 4 AND gm.ClerkId = @RefId THEN 1
				 ELSE 0
			  END = 1
                AND g.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (g.Title LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), g.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    --OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                   -- OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (g.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (g.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
                CASE WHEN @OrderBy = 1 THEN g.Title END DESC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                        WHEN g.GalleryToType = 1 THEN 'Student'
                        WHEN g.GalleryToType = 2 THEN 'Class'
                        WHEN g.GalleryToType = 3 THEN 'Teacher'
                        WHEN g.GalleryToType = 4 THEN 'Clerk'
                        WHEN g.GalleryToType = 5 THEN 'Cab Driver'
                    END
                END DESC,
				
                CASE WHEN @OrderBy = 2 THEN g.StartDate END DESC,
                --CASE WHEN @OrderBy = 3 THEN h.EndDate END DESC,
                CASE WHEN @OrderBy = 3 THEN g.IsPublished END DESC,
                CASE WHEN @OrderBy = 4 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END DESC,
                CASE WHEN @OrderBy = 5 THEN g.CreatedDate END DESC,
                CASE WHEN @OrderBy = 6 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END DESC,
                CASE WHEN @OrderBy = 7 THEN g.ModifiedDate END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY
            END

            
        END
        ELSE
        BEGIN
         
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
                END AS 'Gallery To',
                g.IsPublished,
                g.IsPublished,
                CASE 
                    WHEN g.IsPublished = 1 THEN 'Published'
                    WHEN g.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                g.StartDate,
                g.Title AS GalleryTitle,
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                g.CreatedDate,
                CASE 
                    WHEN g.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                g.ModifiedDate
            FROM dbo.Gallery AS g
            LEFT JOIN dbo.[User] u ON g.CreatedBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON g.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(g.IsDeleted, 0) <> 1
                   AND g.CreatedBy =
			  CASE WHEN @RoleId > 2 THEN 
				@RefId 
			  ELSE
				g.CreatedBy
			  END
                AND g.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (g.Title LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), g.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    --OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                   -- OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
				   OR (
                        LEN(@SearchText) > 0 AND (
                          (g.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (g.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
               -- h.CreatedDate DESC, -- Newly added homework on top
                CASE WHEN @OrderBy = 1 THEN g.Title END ASC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                        WHEN g.GalleryToType = 1 THEN 'Student'
                        WHEN g.GalleryToType = 2 THEN 'Class'
                        WHEN g.GalleryToType = 3 THEN 'Teacher'
                        WHEN g.GalleryToType = 4 THEN 'Clerk'
                        WHEN g.GalleryToType = 5 THEN 'Cab Driver'
                    END
                    END ASC,
                CASE WHEN @OrderBy = 2 THEN g.StartDate END ASC,
                --CASE WHEN @OrderBy = 3 THEN h.EndDate END ASC,
                CASE WHEN @OrderBy = 3 THEN g.IsPublished END ASC,
                CASE WHEN @OrderBy = 4 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END ASC,
                CASE WHEN @OrderBy = 5 THEN g.CreatedDate END ASC,
                CASE WHEN @OrderBy = 6 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END ASC,
                CASE WHEN @OrderBy = 7 THEN g.ModifiedDate END ASC

            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
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
                END AS 'Gallery To',
                g.IsPublished,
                g.IsPublished,
                CASE 
                    WHEN g.IsPublished = 1 THEN 'Published'
                    WHEN g.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                g.StartDate,
                g.Title AS GalleryTitle,
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                g.CreatedDate,
                CASE 
                    WHEN g.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                g.ModifiedDate
            FROM dbo.Gallery AS g
            LEFT JOIN dbo.[User] u ON g.CreatedBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON g.ModifiedBy = u_modified.UserId 
            INNER JOIN dbo.GalleryMapping gm ON gm.GalleryId = g.GalleryId
            WHERE
                ISNULL(g.IsDeleted, 0) <> 1
                AND g.AcademicYearId = @AcademicYearId
                 AND  CASE
				 WHEN @RoleId = 3 AND gm.TeacherId = @RefId THEN 1
				 WHEN @RoleId = 4 AND gm.ClerkId = @RefId THEN 1
				 ELSE 0
			  END = 1
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (g.Title LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (g.GalleryToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), g.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    --OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                   -- OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
				   OR (
                        LEN(@SearchText) > 0 AND (
                          (g.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (g.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), g.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR g.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
               -- h.CreatedDate DESC, -- Newly added homework on top
                CASE WHEN @OrderBy = 1 THEN g.Title END ASC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                        WHEN g.GalleryToType = 1 THEN 'Student'
                        WHEN g.GalleryToType = 2 THEN 'Class'
                        WHEN g.GalleryToType = 3 THEN 'Teacher'
                        WHEN g.GalleryToType = 4 THEN 'Clerk'
                        WHEN g.GalleryToType = 5 THEN 'Cab Driver'
                    END
                    END ASC,
                CASE WHEN @OrderBy = 2 THEN g.StartDate END ASC,
                --CASE WHEN @OrderBy = 3 THEN h.EndDate END ASC,
                CASE WHEN @OrderBy = 3 THEN g.IsPublished END ASC,
                CASE WHEN @OrderBy = 4 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END ASC,
                CASE WHEN @OrderBy = 5 THEN g.CreatedDate END ASC,
                CASE WHEN @OrderBy = 6 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END ASC,
                CASE WHEN @OrderBy = 7 THEN g.ModifiedDate END ASC

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
    END CATCH 
END



