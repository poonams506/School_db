-- =============================================
-- Author:    Poonam Bhalke
-- Create date: 12/02/2024
-- Description:  This stored procedure is used to get Notice info
-- =============================================
CREATE PROCEDURE uspNoticeGridSelect(@RequestModel NVARCHAR(MAX),
@UserId INT)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @NoticeTypeId SMALLINT = JSON_VALUE(@RequestModel, '$.noticeTypeTo');
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

        IF(@NoticeTypeId = 1)
        BEGIN
           SET @RefId = @UserId
        END
        IF @NoticeTypeId = 1
          BEGIN
            SELECT COUNT(h.NoticeId)
            FROM dbo.Notice AS h
           LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
            --INNER JOIN dbo.NoticeMapping m ON m.NoticeId = h.NoticeId
            WHERE
                ISNULL(h.IsDeleted, 0) <> 1
                   AND h.CreatedBy =
			  CASE WHEN @RoleId > 2 THEN 
				@RefId 
			  ELSE
				h.CreatedBy
			  END
                AND h.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (h.Title LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                )); 
          END
        ELSE IF @NoticeTypeId = 2
        BEGIN
             SELECT COUNT(h.NoticeId)
            FROM dbo.Notice AS h
           LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
            INNER JOIN dbo.NoticeMapping m ON m.NoticeId = h.NoticeId
            WHERE
                ISNULL(h.IsDeleted, 0) <> 1
                  AND  CASE
				 WHEN @RoleId = 3 AND m.TeacherId = @RefId THEN 1
				 WHEN @RoleId = 4 AND m.ClerkId = @RefId THEN 1
				 ELSE 0
			  END = 1
                AND h.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (h.Title LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                )); 
        END
        

                                                      

        IF (@OrderBy_ASC_DESC = 'desc')
        BEGIN

           IF @NoticeTypeId = 1
             BEGIN
                 SELECT 
                h.NoticeToType,
                CASE 
                    WHEN h.NoticeToType = 1 THEN 'Student'
                    WHEN h.NoticeToType = 2 THEN 'Class'
                    WHEN h.NoticeToType = 3 THEN 'Teacher'
                    WHEN h.NoticeToType = 4 THEN 'Clerk'
                    WHEN h.NoticeToType = 5 THEN 'Cab Driver'
                END AS 'Notice To',
				h.NoticeId,
                h.Description AS NoticeDescription,
                h.EndDate,
                h.IsPublished,
                CASE 
                    WHEN h.IsPublished = 1 THEN 'Published'
                    WHEN h.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                h.StartDate,
                h.Title AS NoticeTitle,
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                h.CreatedDate,
                CASE 
                    WHEN h.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                h.ModifiedDate
            FROM dbo.Notice AS h
            LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(h.IsDeleted, 0) <> 1
                   AND h.CreatedBy =
			  CASE WHEN @RoleId > 2 THEN 
				@RefId 
			  ELSE
				h.CreatedBy
			  END
                AND h.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (h.Title LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
                CASE WHEN @OrderBy = 1 THEN h.Title END DESC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                        WHEN h.NoticeToType = 1 THEN 'Student'
                        WHEN h.NoticeToType = 2 THEN 'Class'
                        WHEN h.NoticeToType = 3 THEN 'Teacher'
                        WHEN h.NoticeToType = 4 THEN 'Clerk'
                        WHEN h.NoticeToType = 5 THEN 'Cab Driver'
                    END
                END DESC,
				
                CASE WHEN @OrderBy = 2 THEN h.StartDate END DESC,
                CASE WHEN @OrderBy = 3 THEN h.EndDate END DESC,
                CASE WHEN @OrderBy = 4 THEN h.IsPublished END DESC,
                CASE WHEN @OrderBy = 5 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END DESC,
                CASE WHEN @OrderBy = 6 THEN h.CreatedDate END DESC,
                CASE WHEN @OrderBy = 7 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END DESC,
                CASE WHEN @OrderBy = 8 THEN h.ModifiedDate END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY
             END
           ELSE IF @NoticeTypeId = 2
            BEGIN
               SELECT 
                h.NoticeToType,
                CASE 
                    WHEN h.NoticeToType = 1 THEN 'Student'
                    WHEN h.NoticeToType = 2 THEN 'Class'
                    WHEN h.NoticeToType = 3 THEN 'Teacher'
                    WHEN h.NoticeToType = 4 THEN 'Clerk'
                    WHEN h.NoticeToType = 5 THEN 'Cab Driver'
                END AS 'Notice To',
				h.NoticeId,
                h.Description AS NoticeDescription,
                h.EndDate,
                h.IsPublished,
                CASE 
                    WHEN h.IsPublished = 1 THEN 'Published'
                    WHEN h.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                h.StartDate,
                h.Title AS NoticeTitle,
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                h.CreatedDate,
                CASE 
                    WHEN h.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                h.ModifiedDate
            FROM dbo.Notice AS h
            LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
            INNER JOIN dbo.NoticeMapping m ON m.NoticeId = h.NoticeId
            WHERE
                ISNULL(h.IsDeleted, 0) <> 1
                  AND  CASE
				 WHEN @RoleId = 3 AND m.TeacherId = @RefId THEN 1
				 WHEN @RoleId = 4 AND m.ClerkId = @RefId THEN 1
				 ELSE 0
			  END = 1
                AND h.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (h.Title LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    --OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
					 OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
                CASE WHEN @OrderBy = 1 THEN h.Title END DESC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                        WHEN h.NoticeToType = 1 THEN 'Student'
                        WHEN h.NoticeToType = 2 THEN 'Class'
                        WHEN h.NoticeToType = 3 THEN 'Teacher'
                        WHEN h.NoticeToType = 4 THEN 'Clerk'
                        WHEN h.NoticeToType = 5 THEN 'Cab Driver'
                    END
                END DESC,
				
                CASE WHEN @OrderBy = 2 THEN h.StartDate END DESC,
                CASE WHEN @OrderBy = 3 THEN h.EndDate END DESC,
                CASE WHEN @OrderBy = 4 THEN h.IsPublished END DESC,
                CASE WHEN @OrderBy = 5 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END DESC,
                CASE WHEN @OrderBy = 6 THEN h.CreatedDate END DESC,
                CASE WHEN @OrderBy = 7 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END DESC,
                CASE WHEN @OrderBy = 8 THEN h.ModifiedDate END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY
            END

            
        END
        ELSE
        BEGIN
         
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
                END AS 'Notice To',
                h.EndDate,
                h.IsPublished,
                h.IsPublished,
                CASE 
                    WHEN h.IsPublished = 1 THEN 'Published'
                    WHEN h.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                h.StartDate,
                h.Title AS NoticeTitle,
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                h.CreatedDate,
                CASE 
                    WHEN h.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                h.ModifiedDate
            FROM dbo.Notice AS h
            LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(h.IsDeleted, 0) <> 1
                   AND h.CreatedBy =
			  CASE WHEN @RoleId > 2 THEN 
				@RefId 
			  ELSE
				h.CreatedBy
			  END
                AND h.AcademicYearId = @AcademicYearId
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (h.Title LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                   -- OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
				   OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
               -- h.CreatedDate DESC, -- Newly added homework on top
                CASE WHEN @OrderBy = 1 THEN h.Title END ASC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                        WHEN h.NoticeToType = 1 THEN 'Student'
                        WHEN h.NoticeToType = 2 THEN 'Class'
                        WHEN h.NoticeToType = 3 THEN 'Teacher'
                        WHEN h.NoticeToType = 4 THEN 'Clerk'
                        WHEN h.NoticeToType = 5 THEN 'Cab Driver'
                    END
                    END ASC,
                CASE WHEN @OrderBy = 2 THEN h.StartDate END ASC,
                CASE WHEN @OrderBy = 3 THEN h.EndDate END ASC,
                CASE WHEN @OrderBy = 4 THEN h.IsPublished END ASC,
                CASE WHEN @OrderBy = 5 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END ASC,
                CASE WHEN @OrderBy = 6 THEN h.CreatedDate END ASC,
                CASE WHEN @OrderBy = 7 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END ASC,
                CASE WHEN @OrderBy = 8 THEN h.ModifiedDate END ASC

            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
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
                END AS 'Notice To',
                h.EndDate,
                h.IsPublished,
                h.IsPublished,
                CASE 
                    WHEN h.IsPublished = 1 THEN 'Published'
                    WHEN h.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                h.StartDate,
                h.Title AS NoticeTitle,
                concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) AS 'CreatedBy',
                h.CreatedDate,
                CASE 
                    WHEN h.ModifiedDate IS NULL THEN ''
                    ELSE concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname)
                END AS 'ModifiedBy',
                h.ModifiedDate
            FROM dbo.Notice AS h
            LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
            INNER JOIN dbo.NoticeMapping m ON m.NoticeId = h.NoticeId
            WHERE
                ISNULL(h.IsDeleted, 0) <> 1
                AND h.AcademicYearId = @AcademicYearId
                 AND  CASE
				 WHEN @RoleId = 3 AND m.TeacherId = @RefId THEN 1
				 WHEN @RoleId = 4 AND m.ClerkId = @RefId THEN 1
				 ELSE 0
			  END = 1
                AND (LEN(@SearchText) = 0 OR
                    (LEN(@SearchText) > 0 AND (h.Title LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 1 AND 'Student' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 2 AND 'Class' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 3 AND 'Teacher' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 4 AND 'Clerk' LIKE '%' + @SearchText + '%')
                    OR (h.NoticeToType = 5 AND 'Cab Driver' LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                   -- OR LEN(@SearchText) > 0 AND (IIF(h.IsPublished = 1, 'Published', 'Unpublished') LIKE '%' + @SearchText + '%')
				   OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR concat(u.Fname ,' ' ,u.Mname , ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.CreatedDate LIKE '%' + @SearchText + '%'
                    OR concat(u_modified.Fname , ' ' ,u_modified.Mname , ' ' , u_modified.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                ))
            ORDER BY
               -- h.CreatedDate DESC, -- Newly added homework on top
                CASE WHEN @OrderBy = 1 THEN h.Title END ASC,
                CASE WHEN @OrderBy = 0 THEN
                    CASE 
                        WHEN h.NoticeToType = 1 THEN 'Student'
                        WHEN h.NoticeToType = 2 THEN 'Class'
                        WHEN h.NoticeToType = 3 THEN 'Teacher'
                        WHEN h.NoticeToType = 4 THEN 'Clerk'
                        WHEN h.NoticeToType = 5 THEN 'Cab Driver'
                    END
                    END ASC,
                CASE WHEN @OrderBy = 2 THEN h.StartDate END ASC,
                CASE WHEN @OrderBy = 3 THEN h.EndDate END ASC,
                CASE WHEN @OrderBy = 4 THEN h.IsPublished END ASC,
                CASE WHEN @OrderBy = 5 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END ASC,
                CASE WHEN @OrderBy = 6 THEN h.CreatedDate END ASC,
                CASE WHEN @OrderBy = 7 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END ASC,
                CASE WHEN @OrderBy = 8 THEN h.ModifiedDate END ASC

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

