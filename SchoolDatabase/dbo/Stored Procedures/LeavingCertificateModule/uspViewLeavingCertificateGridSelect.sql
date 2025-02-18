-- =============================================
-- Author:   POONAM BHALKE
-- Create date: 24/06/2024
-- Description:  This stored procedure is used to get History Of  Leaving Certificate
-- =============================================
CREATE PROCEDURE [dbo].[uspViewLeavingCertificateGridSelect] 
(
    @RequestModel NVARCHAR(MAX)
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
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

        -- Get total count of records
        SELECT COUNT(c.LeavingCertificateAuditsId)
        FROM LeavingCertificateAudits c
        INNER JOIN Student s ON c.StudentId = s.StudentId
        INNER JOIN Grade g ON c.GradeId = g.GradeId
        INNER JOIN Division d ON c.DivisionId = d.DivisionId
        WHERE ISNULL(c.IsDeleted, 0) <> 1 
          AND ISNULL(s.IsDeleted, 0) <> 1
          AND (
              LEN(@SearchText) = 0
           --   OR (c.SerialNumber LIKE '%' + @SearchText + '%')
              OR (CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) LIKE '%' + @SearchText + '%')
              OR (CONCAT(g.GradeName, '-', d.DivisionName) LIKE '%' + @SearchText + '%')
              OR (s.GeneralRegistrationNo LIKE '%' + @SearchText + '%')
              OR (c.DateOfLeavingTheSchool LIKE '%' + @SearchText + '%')
              OR (CONVERT(NVARCHAR(10), c.DateOfLeavingTheSchool, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0)
              OR (c.DateSignCurrent LIKE '%' + @SearchText + '%')
              OR (CONVERT(NVARCHAR(10), c.DateSignCurrent, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0)
              OR (c.StatusId LIKE '%' + @SearchText + '%')
              OR (c.CreatedDate LIKE '%' + @SearchText + '%')
              OR (CONVERT(NVARCHAR(10), c.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0)
          );
        IF(@OrderBy_ASC_DESC='desc')
       BEGIN

        -- Retrieve paginated records with ordering
         SELECT 
          --  c.SerialNumber,
            CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) AS StudentName,
            CONCAT(g.GradeName, '-', d.DivisionName) AS Class,
            s.GeneralRegistrationNo,
            c.StatusId,
            c.DateSignCurrent,
            c.CreatedDate,
            c.DateOfLeavingTheSchool
        FROM LeavingCertificateAudits c
        INNER JOIN Student s ON c.StudentId = s.StudentId
        INNER JOIN Grade g ON c.GradeId = g.GradeId
        INNER JOIN Division d ON c.DivisionId = d.DivisionId
        WHERE ISNULL(c.IsDeleted, 0) <> 1 
          AND ISNULL(s.IsDeleted, 0) <> 1
          AND (
              LEN(@SearchText) = 0
             --  OR (c.SerialNumber LIKE '%' + @SearchText + '%')
              OR (CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) LIKE '%' + @SearchText + '%')
              OR (CONCAT(g.GradeName, '-', d.DivisionName) LIKE '%' + @SearchText + '%')
              OR (s.GeneralRegistrationNo LIKE '%' + @SearchText + '%')
              OR (c.DateOfLeavingTheSchool LIKE '%' + @SearchText + '%')
              OR (CONVERT(NVARCHAR(10), c.DateOfLeavingTheSchool, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0)
              OR (c.DateSignCurrent LIKE '%' + @SearchText + '%')
              OR (CONVERT(NVARCHAR(10), c.DateSignCurrent, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0)
              OR (c.StatusId LIKE '%' + @SearchText + '%')
              OR (c.CreatedDate LIKE '%' + @SearchText + '%')
              OR (CONVERT(NVARCHAR(10), c.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0)
          )
        ORDER BY
         --   CASE WHEN @OrderBy = 0 THEN c.SerialNumber END DESC,
            CASE WHEN @OrderBy = 0 THEN CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) END DESC,
			CASE WHEN @OrderBy = 1 THEN CONCAT(g.GradeName, '-', d.DivisionName) END DESC,
            CASE WHEN @OrderBy = 2 THEN s.GeneralRegistrationNo END DESC,
            CASE WHEN @OrderBy = 3 THEN c.DateSignCurrent END DESC,
            CASE WHEN @OrderBy = 4 THEN c.StatusId END DESC,
            CASE WHEN @OrderBy = 5 THEN c.CreatedDate END DESC,
            CASE WHEN @OrderBy = 6 THEN c.DateOfLeavingTheSchool END DESC

            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
                                
 END
 ELSE
 BEGIN

        SELECT 
          --  c.SerialNumber,
            CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) AS StudentName,
            CONCAT(g.GradeName, '-', d.DivisionName) AS Class,
            s.GeneralRegistrationNo,
            c.StatusId,
            c.DateSignCurrent,
            c.CreatedDate,
            c.DateOfLeavingTheSchool
        FROM LeavingCertificateAudits c
        INNER JOIN Student s ON c.StudentId = s.StudentId
        INNER JOIN Grade g ON c.GradeId = g.GradeId
        INNER JOIN Division d ON c.DivisionId = d.DivisionId
        WHERE ISNULL(c.IsDeleted, 0) <> 1 
          AND ISNULL(s.IsDeleted, 0) <> 1
          AND (
              LEN(@SearchText) = 0
          --    OR (c.SerialNumber LIKE '%' + @SearchText + '%')
              OR (CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) LIKE '%' + @SearchText + '%')
              OR (CONCAT(g.GradeName, '-', d.DivisionName) LIKE '%' + @SearchText + '%')
              OR (s.GeneralRegistrationNo LIKE '%' + @SearchText + '%')
              OR (c.DateOfLeavingTheSchool LIKE '%' + @SearchText + '%')
              OR (CONVERT(NVARCHAR(10), c.DateOfLeavingTheSchool, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0)
              OR (c.DateSignCurrent LIKE '%' + @SearchText + '%')
              OR (CONVERT(NVARCHAR(10), c.DateSignCurrent, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0)
              OR (c.StatusId LIKE '%' + @SearchText + '%')
              OR (c.CreatedDate LIKE '%' + @SearchText + '%')
              OR (CONVERT(NVARCHAR(10), c.CreatedDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0)
          )
        ORDER BY
            --CASE WHEN @OrderBy = 0 THEN c.SerialNumber END ASC,
            CASE WHEN @OrderBy = 0 THEN CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) END ASC,
			CASE WHEN @OrderBy = 1 THEN CONCAT(g.GradeName, '-', d.DivisionName) END ASC,
            CASE WHEN @OrderBy = 2 THEN s.GeneralRegistrationNo END ASC,
            CASE WHEN @OrderBy = 3 THEN c.DateSignCurrent END ASC,
            CASE WHEN @OrderBy = 4 THEN c.StatusId END ASC,
            CASE WHEN @OrderBy = 5 THEN c.CreatedDate END ASC,
            CASE WHEN @OrderBy = 6 THEN c.DateOfLeavingTheSchool END ASC

            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
    END
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
    END CATCH;
END



