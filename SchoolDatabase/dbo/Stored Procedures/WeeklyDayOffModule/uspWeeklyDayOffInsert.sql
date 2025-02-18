-- =============================================
-- Author:    Poonam Bhalke
-- Create date: 29/02/2024
-- Description:  This stored procedure is used insert FeeParticular data
-- =============================================
CREATE PROCEDURE uspWeeklyDayOffInsert
(
	@AcademicYearId SMALLINT,
	@WeeklyOffId BIGINT,
    @UserId INT,
	@WeeklyDayOffs dbo.[WeekDays] READONLY

)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
  DECLARE @CurrentDateTime DATETIME = GETDATE();
  BEGIN TRY
  
		Delete From WeeklyOff 

     		
       INSERT INTO WeeklyOff(AcademicYearId,DayNo,CreatedBy,CreatedDate) 
       SELECT @AcademicYearId, wo.DayNo, @UserId, @CurrentDateTime FROM @WeeklyDayOffs wo
	 
      
END TRY BEGIN CATCH 
 DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
        EXEC uspExceptionLogInsert @ErrorLine, @ErrorMessage, @ErrorNumber, @ErrorProcedure, @ErrorSeverity, @ErrorState;
END CATCH 
END

