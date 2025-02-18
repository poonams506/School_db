
-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 05/01/2024
-- Description:  This stored procedure is used to get Class Time Table by Class Id
-- =============================================
CREATE PROC dbo.uspClassTimeTableSelect(@ClassId INT)
AS
BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

  DECLARE @GradeId INT;
  DECLARE @DivisionId INT;
  DECLARE @GradeName NVARCHAR(100);
  DECLARE @DivisionName NVARCHAR(100);
  

  SELECT TOP (1) @GradeId=sgdm.GradeId,@DivisionId=sgdm.DivisionId,
  @GradeName=g.GradeName,@DivisionName=d.DivisionName
  FROM
  dbo.SchoolGradeDivisionMatrix sgdm JOIN
  dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
  dbo.Division d ON sgdm.DivisionId=d.DivisionId
  WHERE  sgdm.SchoolGradeDivisionMatrixId=@ClassId
  ORDER BY sgdm.SchoolGradeDivisionMatrixId DESC;

  SELECT @ClassId AS ClassId,@GradeId AS GradeId,@GradeName AS GradeName,
	     @DivisionId AS DivisionId,@DivisionName AS DivisionName,
		 CONCAT(@GradeName,' - ',@DivisionName) AS ClassName;

  SELECT @ClassId AS ClassId,ClassTimeTableId,ClassTimeTableName,clt.isActive
  FROM dbo.ClassTimeTable clt
  WHERE GradeId=@GradeId AND DivisionId=@DivisionId AND clt.isDeleted<>1; 

  SELECT ct.ClassTimeTableId,cdr.PeriodTypeId,cdr.StartingHour,
	cdr.StartingMinute,cdr.EndingHour,cdr.EndingMinute,cdr.ClassTimeTableRowDetailId AS SequenceId
  FROM dbo.ClassTimeTable ct JOIN
  dbo.ClassTimeTableRowDetail cdr ON ct.ClassTimeTableId=cdr.ClassTimeTableId
  WHERE ct.GradeId=@GradeId AND ct.DivisionId=@DivisionId  AND ct.isDeleted<>1;

  SELECT ct.ClassTimeTableId,cdc.ClassTimeTableRowDetailId,cdc.DayNo AS [Day],
	cdc.SubjectId,cdc.TeacherId,cdc.ClassTimeTableRowDetailId AS SequenceId
  FROM dbo.ClassTimeTable ct JOIN
  dbo.ClassTimeTableColumnDetail cdc ON ct.ClassTimeTableId=cdc.ClassTimeTableId
  WHERE ct.GradeId=@GradeId AND ct.DivisionId=@DivisionId AND ct.isDeleted<>1;

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
