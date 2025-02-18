-- =============================================
-- Author:   POONAM BHALKE
-- Create date: 07/03/2024
-- Description:  This stored procedure is used to get School Vacation grid data
-- =============================================
CREATE PROCEDURE uspSchoolVacationGridSelect 
(
    @RequestModel NVARCHAR(MAX)
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
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

        SELECT COUNT(sv.SchoolVacationId)
        FROM SchoolVacation sv
        WHERE
            ISNULL(sv.IsDeleted,0) <> 1 
            AND sv.AcademicYearId = @AcademicYearId
            AND (
                    LEN(@SearchText) = 0
                    OR LEN(@SearchText) > 0 AND (sv.StartDate LIKE '%'+@SearchText+'%')
                    OR LEN(@SearchText) > 0 AND (sv.EndDate LIKE '%'+@SearchText+'%')
                    OR LEN(@SearchText) > 0 AND (sv.VacationName LIKE '%'+@SearchText+'%')
                    OR CONVERT(NVARCHAR(10), sv.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR CONVERT(NVARCHAR(10), sv.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR sv.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                    OR sv.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                );

        IF(@OrderBy_ASC_DESC = 'desc')
        BEGIN
            SELECT 
                sv.SchoolVacationId,
                sv.AcademicYearId,
                sv.VacationName,
                sv.StartDate,
                sv.EndDate
            FROM 
                SchoolVacation sv
            WHERE
                ISNULL(sv.IsDeleted,0) <> 1 
                AND sv.AcademicYearId = @AcademicYearId
                AND (
                        LEN(@SearchText) = 0
                        OR LEN(@SearchText) > 0 AND (sv.StartDate LIKE '%'+@SearchText+'%')
                        OR LEN(@SearchText) > 0 AND (sv.EndDate LIKE '%'+@SearchText+'%')
                        OR LEN(@SearchText) > 0 AND (sv.VacationName LIKE '%'+@SearchText+'%')
                        OR CONVERT(NVARCHAR(10), sv.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR CONVERT(NVARCHAR(10), sv.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR sv.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                        OR sv.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    )
            ORDER BY
                CASE  WHEN @OrderBy = 0 THEN sv.VacationName END DESC,
                CASE  WHEN @OrderBy = 1 THEN sv.StartDate END DESC,
                CASE  WHEN @OrderBy = 2 THEN sv.EndDate END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
        ELSE
        BEGIN
            SELECT 
                sv.SchoolVacationId,
                sv.AcademicYearId,
                sv.VacationName,
                sv.StartDate,
                sv.EndDate
            FROM 
                SchoolVacation sv
            WHERE
                ISNULL(sv.IsDeleted,0) <> 1 
                AND sv.AcademicYearId = @AcademicYearId
                AND (
                        LEN(@SearchText) = 0
                        OR LEN(@SearchText) > 0 AND (sv.StartDate LIKE '%'+@SearchText+'%')
                        OR LEN(@SearchText) > 0 AND (sv.EndDate LIKE '%'+@SearchText+'%')
                        OR LEN(@SearchText) > 0 AND (sv.VacationName LIKE '%'+@SearchText+'%')
                        OR CONVERT(NVARCHAR(10), sv.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR CONVERT(NVARCHAR(10), sv.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                        OR sv.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
                        OR sv.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
                    )
            ORDER BY
                CASE  WHEN @OrderBy = 0 THEN sv.VacationName END ASC,
                CASE  WHEN @OrderBy = 1 THEN sv.StartDate END ASC,
                CASE  WHEN @OrderBy = 2 THEN sv.EndDate END ASC
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
