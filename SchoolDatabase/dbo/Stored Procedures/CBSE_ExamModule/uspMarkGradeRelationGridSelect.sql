--===============================================
-- Author:- Tejas Rahane
-- Create date:- 25-07-2024
-- Description:- GridSelect Stored Procedure for Marks Grade
-- =============================================
CREATE PROC uspCBSE_MarksGradeRelationGridSelect(@RequestModel NVARCHAR(MAX)) AS BEGIN
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;


    BEGIN TRY
        DECLARE @PageSize INT = JSON_VALUE(@RequestModel, '$.getListModel.length');
        DECLARE @PageNumber INT = JSON_VALUE(@RequestModel, '$.getListModel.start');
        DECLARE @SearchText NVARCHAR(150) = JSON_VALUE(@RequestModel, '$.getListModel.search.value');
        DECLARE @OrderBy INT = JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
        DECLARE @OrderBy_ASC_DESC NVARCHAR(20) = JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');
        DECLARE @AcademicYearId INT = JSON_VALUE(@RequestModel, '$.academicYearId');

        -- Count the total records
        SELECT COUNT(mr.MarksGradeRelationId)
        FROM CBSE_MarksGradeRelation AS mr
        WHERE mr.AcademicYearId = @AcademicYearId
          AND ISNULL(mr.IsDeleted, 0) <> 1
          AND (LEN(@SearchText) = 0 
               OR mr.MaxMark LIKE '%' + @SearchText + '%' 
               OR mr.MinMark LIKE '%' + @SearchText + '%' 
               OR mr.Grade LIKE '%' + @SearchText + '%');

        -- Fetch paginated records
        IF(@OrderBy_ASC_DESC = 'desc')
        BEGIN
            SELECT
                mr.MarksGradeRelationId,

                mr.MaxMark,
                mr.MinMark,
                mr.Grade
            FROM CBSE_MarksGradeRelation AS mr
            WHERE mr.AcademicYearId = @AcademicYearId
              AND ISNULL(mr.IsDeleted, 0) <> 1
              AND (LEN(@SearchText) = 0 
                   OR mr.MaxMark LIKE '%' + @SearchText + '%' 
                   OR mr.MinMark LIKE '%' + @SearchText + '%' 
                   OR mr.Grade LIKE '%' + @SearchText + '%')
            ORDER BY
			    CASE WHEN @OrderBy = 0 THEN mr.Grade END DESC,
                CASE WHEN @OrderBy = 1 THEN mr.MinMark END DESC,
                CASE WHEN @OrderBy = 2 THEN mr.MaxMark END DESC
                
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
        ELSE
        BEGIN
            SELECT
                mr.MarksGradeRelationId,
                mr.MaxMark,
                mr.MinMark,
                mr.Grade
            FROM CBSE_MarksGradeRelation AS mr
            WHERE mr.AcademicYearId = @AcademicYearId
              AND ISNULL(mr.IsDeleted, 0) <> 1
              AND (LEN(@SearchText) = 0 
                   OR mr.MaxMark LIKE '%' + @SearchText + '%' 
                   OR mr.MinMark LIKE '%' + @SearchText + '%' 
                   OR mr.Grade LIKE '%' + @SearchText + '%')
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN mr.Grade END ASC,
                CASE WHEN @OrderBy = 1 THEN mr.MinMark END ASC,
                CASE WHEN @OrderBy = 2 THEN mr.MaxMark END ASC
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
END;
