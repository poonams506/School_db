-- =============================================
-- Author:    Poonam Bhalke
-- Create date:  20/02/2024
-- Description:  This stored procedure is used to get  SchoolHoliday Info
-- =================================================================
CREATE PROC uspSchoolHolidayGridSelect(@RequestModel NVARCHAR(MAX)) AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY
      --  DECLARE @GradeId SMALLINT = JSON_VALUE(@RequestModel, '$.gradeId');
      --  DECLARE @DivisionId SMALLINT = JSON_VALUE(@RequestModel, '$.divisionId');
        DECLARE @PageSize INT = JSON_VALUE(@RequestModel, '$.getListModel.length');
        DECLARE @PageNumber INT = JSON_VALUE(@RequestModel, '$.getListModel.start');
        DECLARE @SearchText NVARCHAR(150) = JSON_VALUE(@RequestModel, '$.getListModel.search.value');
        DECLARE @OrderBy INT = JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
        DECLARE @OrderBy_ASC_DESC NVARCHAR(20) = JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');
        DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
         DECLARE @SearchDate DATE;
        
        IF ISDATE(@SearchText) = 1
        BEGIN
            SET @SearchDate = CONVERT(DATE, @SearchText, 103);
        END
        
        -- Retrieve the count of schoolholiday records
       SELECT COUNT(sh.SchoolHolidayId)
       FROM dbo.SchoolHolidays AS sh
         INNER JOIN AcademicYear a ON sh.AcademicYearId = a.AcademicYearId
       WHERE
		 ISNULL(sh.IsDeleted, 0) <> 1
         AND sh.AcademicYearId = @AcademicYearId
         AND (LEN(@SearchText) = 0 
		            OR LEN(@SearchText) > 0 AND (sh.DayNo LIKE +@SearchText + '%'
                    OR sh.CalendarDate LIKE '%' + @SearchText + '%'
                    OR sh.HolidayReason LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), sh.CalendarDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR sh.CalendarDate = @SearchDate AND ISDATE(@SearchText) = 1
            );
        -- Retrieve schoolholiday information
        IF @OrderBy_ASC_DESC = 'desc'
        BEGIN
            SELECT
         sh.SchoolHolidayId,
         sh.AcademicYearId,
         sh.DayNo,
         sh.CalendarDate,
         sh.HolidayReason
       FROM dbo.SchoolHolidays As sh
         INNER JOIN AcademicYear a ON sh.AcademicYearId = a.AcademicYearId
       WHERE
		 ISNULL(sh.IsDeleted, 0) <> 1
         AND sh.AcademicYearId = @AcademicYearId
         AND (LEN(@SearchText) = 0 
		            OR LEN(@SearchText) > 0 AND (sh.DayNo LIKE +@SearchText + '%'
                    OR sh.CalendarDate LIKE '%' + @SearchText + '%'
                    OR sh.HolidayReason LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), sh.CalendarDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR sh.CalendarDate = @SearchDate AND ISDATE(@SearchText) = 1
            )
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN sh.CalendarDate END DESC,
                CASE WHEN @OrderBy = 1 THEN sh.HolidayReason END DESC,
                CASE WHEN @OrderBy = 2 THEN sh.DayNo END DESC

                
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
        ELSE
        BEGIN
             SELECT
         sh.SchoolHolidayId,
         sh.AcademicYearId,
         sh.DayNo,
         sh.CalendarDate,
         sh.HolidayReason
       FROM dbo.SchoolHolidays As sh
         INNER JOIN AcademicYear a ON sh.AcademicYearId = a.AcademicYearId
       WHERE
		 ISNULL(sh.IsDeleted, 0) <> 1
         AND sh.AcademicYearId = @AcademicYearId
         AND (LEN(@SearchText) = 0 
		            OR LEN(@SearchText) > 0 AND (sh.DayNo LIKE +@SearchText + '%'
                    OR sh.CalendarDate LIKE '%' + @SearchText + '%'
                    OR sh.HolidayReason LIKE '%' + @SearchText + '%')
                    OR CONVERT(NVARCHAR(10), sh.CalendarDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
                    OR sh.CalendarDate = @SearchDate AND ISDATE(@SearchText) = 1
            )
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN sh.CalendarDate END ASC,
                CASE WHEN @OrderBy = 1 THEN sh.HolidayReason END ASC,
                CASE WHEN @OrderBy = 2 THEN sh.DayNo END ASC

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
        EXEC dbo.uspExceptionLogInsert @ErrorLine,
            @ErrorMessage,
            @ErrorNumber,
            @ErrorProcedure,
            @ErrorSeverity,
            @ErrorState;
    END CATCH

END
