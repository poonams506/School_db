
-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 29/03/2024
-- Description:  This stored procedure is used to get Class Time Table by Id
-- =============================================
CREATE PROC dbo.uspClassTimeTableSelectById(@ClassTimeTableId INT)
AS
BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 


  SELECT ClassTimeTableId,ClassTimeTableName
  FROM dbo.ClassTimeTable clt
  WHERE clt.ClassTimeTableId=@ClassTimeTableId AND clt.isDeleted=0; 

  SELECT ct.ClassTimeTableId,cdr.PeriodTypeId,cdr.StartingHour,
	cdr.StartingMinute,cdr.EndingHour,cdr.EndingMinute,cdr.ClassTimeTableRowDetailId AS SequenceId
  FROM dbo.ClassTimeTable ct JOIN
  dbo.ClassTimeTableRowDetail cdr ON ct.ClassTimeTableId=cdr.ClassTimeTableId
  WHERE ct.ClassTimeTableId=@ClassTimeTableId AND ct.isDeleted<>1;

  SELECT ct.ClassTimeTableId,cdc.ClassTimeTableRowDetailId,cdc.DayNo AS [Day],
	cdc.SubjectId,cdc.TeacherId,cdc.ClassTimeTableRowDetailId AS SequenceId
  FROM dbo.ClassTimeTable ct JOIN
  dbo.ClassTimeTableColumnDetail cdc ON ct.ClassTimeTableId=cdc.ClassTimeTableId
  WHERE ct.ClassTimeTableId=@ClassTimeTableId AND ct.isDeleted<>1;

  END TRY 
  
  BEGIN CATCH
  
  DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
DECLARE @ErrorState INT = ERROR_STATE();
DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();
DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
EXEC uspExceptionLogInsert @ErrorLine, 
@ErrorMessage, 
@ErrorNumber, 
@ErrorProcedure, 
@ErrorSeverity, 
@ErrorState 

END CATCH
END
GO
