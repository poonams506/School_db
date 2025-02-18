-- =============================================
-- Author:    Poonam Bhalke
-- Create date:  14/05/2024
-- Description:  This stored procedure is used to get  Homework Info
-- =================================================================
CREATE PROC uspHomeWorkGridSelect(@RequestModel NVARCHAR(MAX),@UserId INT) AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
        DECLARE @GradeId SMALLINT = JSON_VALUE(@RequestModel, '$.gradeId');
        DECLARE @DivisionId SMALLINT = JSON_VALUE(@RequestModel, '$.divisionId');
        DECLARE @PageSize INT = JSON_VALUE(@RequestModel, '$.getListModel.length');
        DECLARE @PageNumber INT = JSON_VALUE(@RequestModel, '$.getListModel.start');
        DECLARE @SearchText NVARCHAR(150) = JSON_VALUE(@RequestModel, '$.getListModel.search.value');
        DECLARE @OrderBy INT = JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
        DECLARE @OrderBy_ASC_DESC NVARCHAR(20) = JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');
        DECLARE @SearchDate DATE;
		DECLARE @SuperAdminId INT;
		DECLARE @RoleId INT;

	 SELECT @SuperAdminId = UserId FROM dbo.[UserRole]
		WHERE RoleId=1

		IF @UserId != @SuperAdminId
		BEGIN
		     SELECT @RoleId = RoleId FROM dbo.[UserRole]
		     WHERE UserId = @UserId AND IsDeleted <> 1 AND RoleId = 2
		END

		IF(@UserId = @SuperAdminId or @RoleId = 2)
		BEGIN
        -- Check if the search text is in the format dd/mm/yyyy
        IF ISDATE(@SearchText) = 1
        BEGIN
            SET @SearchDate = CONVERT(DATE, @SearchText, 103); -- Assuming the input format is dd/mm/yyyy (103 is British/French format)
        END
        
        -- Retrieve the count of HomeWork records
        SELECT COUNT(h.HomeWorkId)
        FROM dbo.HomeWork AS h
        INNER JOIN dbo.Grade g ON h.GradeId = g.GradeId
        INNER JOIN dbo.Division d ON h.DivisionId = d.DivisionId
        INNER JOIN dbo.[SubjectMaster] s ON h.SubjectId = s.SubjectMasterId
        LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
        LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
        WHERE
            ISNULL(d.IsDeleted, 0) <> 1
            AND ISNULL(h.IsDeleted, 0) <> 1
            AND ISNULL(g.IsDeleted, 0) <> 1
            AND ISNULL(s.IsDeleted, 0) <> 1
            AND h.AcademicYearId = @AcademicYearId
            --AND (@RoleId = 1 OR h.CreatedBy = @UserId)
            AND (h.GradeId = ISNULL(@GradeId, h.GradeId) OR h.GradeId = @GradeId)
            AND (h.DivisionId = ISNULL(@DivisionId, h.DivisionId) OR h.DivisionId = @DivisionId)
            AND (
                LEN(@SearchText) = 0
                OR LEN(@SearchText) > 0 AND (
                    g.GradeName LIKE +@SearchText + '%'
                    OR d.DivisionName LIKE '%' + @SearchText + '%'
                    OR s.SubjectName LIKE '%' + @SearchText + '%'
                    OR h.Title LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR CONCAT(g.GradeName, ' - ', d.DivisionName) LIKE '%' + @SearchText + '%'
                    OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR CONCAT(u.Fname, ' ', u.Mname, ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.CreatedDate LIKE '%' + @SearchText + '%'
                    OR ISNULL(CONCAT(u_modified.Fname, '', u_modified.Mname, ' ', u_modified.Lname), '') LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                )
            );  
        -- Retrieve HomeWorkDetails information
        IF @OrderBy_ASC_DESC = 'desc'
        BEGIN
            SELECT 
                h.HomeWorkId,
                g.GradeName,
                d.DivisionName,
                h.EndDate,
                h.IsPublished,
                h.StartDate,
                h.Title AS HomeworkTitle,
                s.SubjectName,
                CASE 
                    WHEN h.IsPublished = 1 THEN 'Published'
                    WHEN h.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                CONCAT(g.GradeName, ' - ', d.DivisionName) AS 'Class',
                CONCAT(u.Fname, ' ', u.Mname, ' ', u.Lname)  AS 'CreatedBy',
                h.CreatedDate,
                CASE 
                    WHEN h.ModifiedDate IS NULL THEN ''
                    ELSE ISNULL (CONCAT(u_modified.Fname , ' ',u_modified.Mname , ' ' , u_modified.Lname), '')
                END AS 'ModifiedBy',
                h.ModifiedDate
            FROM dbo.HomeWork AS h
            INNER JOIN dbo.Grade g ON h.GradeId = g.GradeId
            INNER JOIN dbo.Division d ON h.DivisionId = d.DivisionId
            INNER JOIN dbo.[SubjectMaster] s ON h.SubjectId = s.SubjectMasterId
            LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(d.IsDeleted, 0) <> 1
                AND ISNULL(h.IsDeleted, 0) <> 1
                AND ISNULL(g.IsDeleted, 0) <> 1
                AND ISNULL(s.IsDeleted, 0) <> 1
                AND h.AcademicYearId = @AcademicYearId
            --AND (@RoleId = 1 OR h.CreatedBy = @UserId)
                AND (h.GradeId = ISNULL(@GradeId, h.GradeId) OR h.GradeId = @GradeId)
                AND (h.DivisionId = ISNULL(@DivisionId, h.DivisionId) OR h.DivisionId = @DivisionId)
                AND (
                    LEN(@SearchText) = 0
                    OR LEN(@SearchText) > 0 AND (
                        g.GradeName LIKE +@SearchText + '%'
                        OR d.DivisionName LIKE '%' + @SearchText + '%'
                        OR s.SubjectName LIKE '%' + @SearchText + '%'
                        OR h.Title LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                        OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                        OR CONCAT(g.GradeName, ' - ', d.DivisionName) LIKE '%' + @SearchText + '%'
                        OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                          ))
                        OR CONCAT(u.Fname, ' ', u.Mname, ' ', u.Lname) LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.CreatedDate LIKE '%' + @SearchText + '%'
                        OR ISNULL(CONCAT(u_modified.Fname, '', u_modified.Mname, ' ', u_modified.Lname), '') LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                    )
                )
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN CONCAT(g.GradeName, ' - ', d.DivisionName) END DESC,
                CASE WHEN @OrderBy = 1 THEN s.SubjectName END DESC,
                CASE WHEN @OrderBy = 2 THEN h.Title END DESC,
                CASE WHEN @OrderBy = 3 THEN h.StartDate END DESC,
                CASE WHEN @OrderBy = 4 THEN h.EndDate END DESC,
                CASE WHEN @OrderBy = 5 THEN h.IsPublished END DESC,
                CASE WHEN @OrderBy = 6 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END DESC,
                CASE WHEN @OrderBy = 7 THEN h.CreatedDate END DESC,
                CASE WHEN @OrderBy = 8 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END DESC, 
                CASE WHEN @OrderBy = 9 THEN h.ModifiedDate END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
        ELSE
        BEGIN
            SELECT 
                h.HomeWorkId,
                g.GradeName,
                d.DivisionName,
                h.EndDate,
                h.IsPublished,
                h.StartDate,
                h.Title AS HomeworkTitle,
                s.SubjectName,
                CASE 
                    WHEN h.IsPublished = 1 THEN 'Published'
                    WHEN h.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                CONCAT(g.GradeName, ' - ', d.DivisionName) AS 'Class',
                CONCAT(u.Fname, ' ', u.Mname, ' ', u.Lname)  AS 'CreatedBy',
                h.CreatedDate,
                CASE 
                    WHEN h.ModifiedDate IS NULL THEN ''
                    ELSE ISNULL (CONCAT(u_modified.Fname , ' ',u_modified.Mname , ' ' , u_modified.Lname), '')
                END AS 'ModifiedBy',
                h.ModifiedDate
            FROM dbo.HomeWork AS h
            INNER JOIN dbo.Grade g ON h.GradeId = g.GradeId
            INNER JOIN dbo.Division d ON h.DivisionId = d.DivisionId
            INNER JOIN dbo.[SubjectMaster] s ON h.SubjectId = s.SubjectMasterId
            LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(d.IsDeleted, 0) <> 1
                AND ISNULL(h.IsDeleted, 0) <> 1
                AND ISNULL(g.IsDeleted, 0) <> 1
                AND ISNULL(s.IsDeleted, 0) <> 1
                AND h.AcademicYearId = @AcademicYearId
                --AND (@RoleId = 1 OR h.CreatedBy = @UserId)
                AND (h.GradeId = ISNULL(@GradeId, h.GradeId) OR h.GradeId = @GradeId)
                AND (h.DivisionId = ISNULL(@DivisionId, h.DivisionId) OR h.DivisionId = @DivisionId)
                AND (
                    LEN(@SearchText) = 0
                    OR LEN(@SearchText) > 0 AND (
                        g.GradeName LIKE +@SearchText + '%'
                        OR d.DivisionName LIKE '%' + @SearchText + '%'
                        OR s.SubjectName LIKE '%' + @SearchText + '%'
                        OR h.Title LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                        OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                        OR CONCAT(g.GradeName, ' - ', d.DivisionName) LIKE '%' + @SearchText + '%'
                        OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                          ))
                        OR CONCAT(u.Fname, ' ', u.Mname, ' ', u.Lname) LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.CreatedDate LIKE '%' + @SearchText + '%'
                        OR ISNULL(CONCAT(u_modified.Fname, '', u_modified.Mname, ' ', u_modified.Lname), '') LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                    )
                )
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN CONCAT(g.GradeName, ' - ', d.DivisionName) END ASC,
                CASE WHEN @OrderBy = 1 THEN s.SubjectName END ASC,
                CASE WHEN @OrderBy = 2 THEN h.Title END ASC,
                CASE WHEN @OrderBy = 3 THEN h.StartDate END ASC,
                CASE WHEN @OrderBy = 4 THEN h.EndDate END ASC,
                CASE WHEN @OrderBy = 5 THEN h.IsPublished END ASC,
                CASE WHEN @OrderBy = 6 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END ASC,
                CASE WHEN @OrderBy = 7 THEN h.CreatedDate END ASC,
                CASE WHEN @OrderBy = 8 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END ASC, 
                CASE WHEN @OrderBy = 9 THEN h.ModifiedDate END ASC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
        END
		
		ELSE
		BEGIN
        -- Check if the search text is in the format dd/mm/yyyy
        IF ISDATE(@SearchText) = 1
        BEGIN
            SET @SearchDate = CONVERT(DATE, @SearchText, 103); -- Assuming the input format is dd/mm/yyyy (103 is British/French format)
        END
        
        -- Retrieve the count of HomeWork records
        SELECT COUNT(h.HomeWorkId)
        FROM dbo.HomeWork AS h
        INNER JOIN dbo.Grade g ON h.GradeId = g.GradeId
        INNER JOIN dbo.Division d ON h.DivisionId = d.DivisionId
        INNER JOIN dbo.[SubjectMaster] s ON h.SubjectId = s.SubjectMasterId
        LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
        LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
        WHERE
            ISNULL(d.IsDeleted, 0) <> 1
            AND ISNULL(h.IsDeleted, 0) <> 1
            AND ISNULL(g.IsDeleted, 0) <> 1
            AND ISNULL(s.IsDeleted, 0) <> 1
            AND h.AcademicYearId = @AcademicYearId
            AND ( h.CreatedBy = @UserId)
            AND (h.GradeId = ISNULL(@GradeId, h.GradeId) OR h.GradeId = @GradeId)
            AND (h.DivisionId = ISNULL(@DivisionId, h.DivisionId) OR h.DivisionId = @DivisionId)
            AND (
                LEN(@SearchText) = 0
                OR LEN(@SearchText) > 0 AND (
                    g.GradeName LIKE +@SearchText + '%'
                    OR d.DivisionName LIKE '%' + @SearchText + '%'
                    OR s.SubjectName LIKE '%' + @SearchText + '%'
                    OR h.Title LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR CONCAT(g.GradeName, ' - ', d.DivisionName) LIKE '%' + @SearchText + '%'
                    OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                      ))
                    OR CONCAT(u.Fname, ' ', u.Mname, ' ', u.Lname) LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.CreatedDate LIKE '%' + @SearchText + '%'
                    OR ISNULL(CONCAT(u_modified.Fname, '', u_modified.Mname, ' ', u_modified.Lname), '') LIKE '%' + @SearchText + '%'
                    OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                )
            );  
        -- Retrieve HomeWorkDetails information
        IF @OrderBy_ASC_DESC = 'desc'
        BEGIN
            SELECT 
                h.HomeWorkId,
                g.GradeName,
                d.DivisionName,
                h.EndDate,
                h.IsPublished,
                h.StartDate,
                h.Title AS HomeworkTitle,
                s.SubjectName,
                CASE 
                    WHEN h.IsPublished = 1 THEN 'Published'
                    WHEN h.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                CONCAT(g.GradeName, ' - ', d.DivisionName) AS 'Class',
                CONCAT(u.Fname, ' ', u.Mname, ' ', u.Lname)  AS 'CreatedBy',
                h.CreatedDate,
                CASE 
                    WHEN h.ModifiedDate IS NULL THEN ''
                    ELSE ISNULL (CONCAT(u_modified.Fname , ' ',u_modified.Mname , ' ' , u_modified.Lname), '')
                END AS 'ModifiedBy',
                h.ModifiedDate
            FROM dbo.HomeWork AS h
            INNER JOIN dbo.Grade g ON h.GradeId = g.GradeId
            INNER JOIN dbo.Division d ON h.DivisionId = d.DivisionId
            INNER JOIN dbo.[SubjectMaster] s ON h.SubjectId = s.SubjectMasterId
            LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(d.IsDeleted, 0) <> 1
                AND ISNULL(h.IsDeleted, 0) <> 1
                AND ISNULL(g.IsDeleted, 0) <> 1
                AND ISNULL(s.IsDeleted, 0) <> 1
                AND h.AcademicYearId = @AcademicYearId
            AND (h.CreatedBy = @UserId)
                AND (h.GradeId = ISNULL(@GradeId, h.GradeId) OR h.GradeId = @GradeId)
                AND (h.DivisionId = ISNULL(@DivisionId, h.DivisionId) OR h.DivisionId = @DivisionId)
                AND (
                    LEN(@SearchText) = 0
                    OR LEN(@SearchText) > 0 AND (
                        g.GradeName LIKE +@SearchText + '%'
                        OR d.DivisionName LIKE '%' + @SearchText + '%'
                        OR s.SubjectName LIKE '%' + @SearchText + '%'
                        OR h.Title LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                        OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                        OR CONCAT(g.GradeName, ' - ', d.DivisionName) LIKE '%' + @SearchText + '%'
                        OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                          ))
                        OR CONCAT(u.Fname, ' ', u.Mname, ' ', u.Lname) LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.CreatedDate LIKE '%' + @SearchText + '%'
                        OR ISNULL(CONCAT(u_modified.Fname, '', u_modified.Mname, ' ', u_modified.Lname), '') LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                    )
                )
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN CONCAT(g.GradeName, ' - ', d.DivisionName) END DESC,
                CASE WHEN @OrderBy = 1 THEN s.SubjectName END DESC,
                CASE WHEN @OrderBy = 2 THEN h.Title END DESC,
                CASE WHEN @OrderBy = 3 THEN h.StartDate END DESC,
                CASE WHEN @OrderBy = 4 THEN h.EndDate END DESC,
                CASE WHEN @OrderBy = 5 THEN h.IsPublished END DESC,
                CASE WHEN @OrderBy = 6 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END DESC,
                CASE WHEN @OrderBy = 7 THEN h.CreatedDate END DESC,
                CASE WHEN @OrderBy = 8 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END DESC, 
                CASE WHEN @OrderBy = 9 THEN h.ModifiedDate END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
        ELSE
        BEGIN
            SELECT 
                h.HomeWorkId,
                g.GradeName,
                d.DivisionName,
                h.EndDate,
                h.IsPublished,
                h.StartDate,
                h.Title AS HomeworkTitle,
                s.SubjectName,
                CASE 
                    WHEN h.IsPublished = 1 THEN 'Published'
                    WHEN h.IsPublished = 0 THEN 'Unpublished'
                END AS 'Status',
                CONCAT(g.GradeName, ' - ', d.DivisionName) AS 'Class',
                CONCAT(u.Fname, ' ', u.Mname, ' ', u.Lname)  AS 'CreatedBy',
                h.CreatedDate,
                CASE 
                    WHEN h.ModifiedDate IS NULL THEN ''
                    ELSE ISNULL (CONCAT(u_modified.Fname , ' ',u_modified.Mname , ' ' , u_modified.Lname), '')
                END AS 'ModifiedBy',
                h.ModifiedDate
            FROM dbo.HomeWork AS h
            INNER JOIN dbo.Grade g ON h.GradeId = g.GradeId
            INNER JOIN dbo.Division d ON h.DivisionId = d.DivisionId
            INNER JOIN dbo.[SubjectMaster] s ON h.SubjectId = s.SubjectMasterId
            LEFT JOIN dbo.[User] u ON h.createdBy = u.UserId
            LEFT JOIN dbo.[User] u_modified ON h.ModifiedBy = u_modified.UserId 
            WHERE
                ISNULL(d.IsDeleted, 0) <> 1
                AND ISNULL(h.IsDeleted, 0) <> 1
                AND ISNULL(g.IsDeleted, 0) <> 1
                AND ISNULL(s.IsDeleted, 0) <> 1
                AND h.AcademicYearId = @AcademicYearId
                AND (h.CreatedBy = @UserId)
                AND (h.GradeId = ISNULL(@GradeId, h.GradeId) OR h.GradeId = @GradeId)
                AND (h.DivisionId = ISNULL(@DivisionId, h.DivisionId) OR h.DivisionId = @DivisionId)
                AND (
                    LEN(@SearchText) = 0
                    OR LEN(@SearchText) > 0 AND (
                        g.GradeName LIKE +@SearchText + '%'
                        OR d.DivisionName LIKE '%' + @SearchText + '%'
                        OR s.SubjectName LIKE '%' + @SearchText + '%'
                        OR h.Title LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                        OR CONVERT(NVARCHAR(10), h.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                        OR CONCAT(g.GradeName, ' - ', d.DivisionName) LIKE '%' + @SearchText + '%'
                        OR (
                        LEN(@SearchText) > 0 AND (
                          (h.IsPublished = 1 AND 'Published' LIKE '%' + @SearchText + '%') OR
                          (h.IsPublished = 0 AND 'Unpublished' LIKE '%' + @SearchText + '%')
                          ))
                        OR CONCAT(u.Fname, ' ', u.Mname, ' ', u.Lname) LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.CreatedDate LIKE '%' + @SearchText + '%'
                        OR ISNULL(CONCAT(u_modified.Fname, '', u_modified.Mname, ' ', u_modified.Lname), '') LIKE '%' + @SearchText + '%'
                        OR CONVERT(NVARCHAR(10), h.ModifiedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR h.ModifiedDate LIKE '%' + @SearchText + '%'
                    )
                )
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN CONCAT(g.GradeName, ' - ', d.DivisionName) END ASC,
                CASE WHEN @OrderBy = 1 THEN s.SubjectName END ASC,
                CASE WHEN @OrderBy = 2 THEN h.Title END ASC,
                CASE WHEN @OrderBy = 3 THEN h.StartDate END ASC,
                CASE WHEN @OrderBy = 4 THEN h.EndDate END ASC,
                CASE WHEN @OrderBy = 5 THEN h.IsPublished END ASC,
                CASE WHEN @OrderBy = 6 THEN u.Fname + '' + u.Mname + ' ' + u.Lname END ASC,
                CASE WHEN @OrderBy = 7 THEN h.CreatedDate END ASC,
                CASE WHEN @OrderBy = 8 THEN u_modified.Fname + '' + u_modified.Mname + ' ' + u_modified.Lname END ASC, 
                CASE WHEN @OrderBy = 9 THEN h.ModifiedDate END ASC
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
