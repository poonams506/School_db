-- =============================================
-- Author:  Poonam Bhalke
-- Create date: 20/02/2024
-- Description:  This stored procedure is used for insert/update schoolholiday
-- =============================================
CREATE PROCEDURE [dbo].[uspSchoolHolidayInsert]
(
    @AcademicYearId SMALLINT,
    @UserId INT,
    @HolidayDetails dbo.[HolidayDetailsTypes] READONLY
)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @CurrentDateTime DATETIME = GETDATE();

    BEGIN TRY
        -- Delete existing records only if multiple holidays are being inserted
        IF (SELECT COUNT(*) FROM @HolidayDetails) > 0
        BEGIN
            DELETE FROM SchoolHolidays 
            WHERE CalendarDate IN (SELECT CalendarDate FROM @HolidayDetails);
        END

        -- Insert new records
        INSERT INTO SchoolHolidays(AcademicYearId, DayNo, HolidayReason, CalendarDate, CreatedBy, CreatedDate) 
        SELECT @AcademicYearId, hd.DayNo, hd.HolidayReason, hd.CalendarDate, @UserId, @CurrentDateTime 
        FROM @HolidayDetails hd
        WHERE NOT EXISTS (
            SELECT 1 
            FROM SchoolHolidays sh
            WHERE sh.CalendarDate = hd.CalendarDate
        );
      
    END TRY 
    BEGIN CATCH
        -- Error handling
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
    END CATCH
END
