-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 15/01/2024
-- Description:  This stored procedure is used to get Class Time Table by Teacher Id
-- =============================================
CREATE PROC uspTeacherClassTimeTableSelect
(
@TeacherId INT,
@ClassId dbo.SingleIdType READONLY,
@AcademicYearId INT
)
AS
BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

  DECLARE @GradeDivisionTable TABLE(ClassId INT,GradeId INT,DivisionId INT,
		  GradeName NVARCHAR(150),DivisionName NVARCHAR(150));

  
  INSERT INTO @GradeDivisionTable(ClassId,GradeId,DivisionId,GradeName,DivisionName)
  SELECT DISTINCT sgdm.SchoolGradeDivisionMatrixId,sgdm.GradeId,sgdm.DivisionId,g.GradeName,d.DivisionName
  FROM
  dbo.SchoolGradeDivisionMatrix sgdm JOIN
  dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
  dbo.Division d ON sgdm.DivisionId=d.DivisionId JOIN
  dbo.ClassTimeTable ct ON ct.GradeId=g.GradeId AND ct.DivisionId=d.DivisionId AND ct.AcademicYearId=@AcademicYearId
  WHERE  (NOT EXISTS(SELECT TOP (1) Id FROM @ClassId) OR 
		   (EXISTS(SELECT Id FROM @ClassId WHERE Id=sgdm.SchoolGradeDivisionMatrixId)))
		   AND EXISTS (SELECT TOP (1) ClassTimeTableColumnDetailId FROM dbo.ClassTimeTableColumnDetail 
						WHERE ClassTimeTableId=ct.ClassTimeTableId AND TeacherId=@TeacherId)
			AND ct.IsActive=1  AND ct.IsDeleted<>1 AND sgdm.AcademicYearId = @AcademicYearId and sgdm.IsDeleted<>1;

  SELECT ClassId,GradeId,DivisionId,GradeName,DivisionName,
  CONCAT(GradeName,'-',DivisionName) AS ClassName
  FROM
  @GradeDivisionTable;

	
  SELECT gdt.ClassId AS ClassId,ct.ClassTimeTableId,ct.ClassTimeTableName,
  CONCAT(gdt.GradeName,'-',gdt.DivisionName) AS ClassName
  FROM @GradeDivisionTable gdt JOIN
  dbo.ClassTimeTable ct ON ct.GradeId=gdt.GradeId AND 
  ct.DivisionId=gdt.DivisionId AND ct.AcademicYearId=@AcademicYearId
  WHERE ct.IsActive=1  AND ct.IsDeleted<>1;

  SELECT ct.ClassTimeTableId,cdr.PeriodTypeId,cdr.StartingHour,
	cdr.StartingMinute,cdr.EndingHour,cdr.EndingMinute,cdr.ClassTimeTableRowDetailId AS SequenceId
  FROM dbo.ClassTimeTable ct JOIN
  dbo.ClassTimeTableRowDetail cdr ON ct.ClassTimeTableId=cdr.ClassTimeTableId JOIN
  @GradeDivisionTable gdt ON ct.GradeId=gdt.GradeId AND 
  ct.DivisionId=gdt.DivisionId AND ct.AcademicYearId=@AcademicYearId
  WHERE  EXISTS (SELECT TOP (1) ClassTimeTableColumnDetailId FROM dbo.ClassTimeTableColumnDetail 
						WHERE ClassTimeTableId=ct.ClassTimeTableId AND TeacherId=@TeacherId)
		AND ct.IsActive=1  AND ct.IsDeleted<>1;

  SELECT ct.ClassTimeTableId,cdc.DayNo AS [Day],cdc.SubjectId,cdc.TeacherId,
	CASE WHEN ISNULL(t.TeacherId,0)>0 THEN CONCAT(t.FirstName,' ',t.MiddleName,' ',t.LastName) 
	ELSE '' END AS TeacherName,
	CASE WHEN ISNULL(t.TeacherId,0)>0 THEN s.SubjectName ELSE '' END AS SubjectName,
	cdc.ClassTimeTableRowDetailId AS SequenceId
  FROM dbo.ClassTimeTable ct JOIN
  dbo.ClassTimeTableColumnDetail cdc ON ct.ClassTimeTableId=cdc.ClassTimeTableId JOIN
  @GradeDivisionTable gdt ON ct.GradeId=gdt.GradeId AND 
  ct.DivisionId=gdt.DivisionId AND ct.AcademicYearId=@AcademicYearId  
  LEFT JOIN
  dbo.Teacher t ON ISNULL(cdc.TeacherId,0)=t.TeacherId LEFT JOIN
  dbo.SubjectMaster s ON ISNULL(s.SubjectMasterId,0)=cdc.SubjectId
  WHERE t.TeacherId=@TeacherId 
   AND EXISTS (SELECT TOP (1) ClassTimeTableColumnDetailId FROM dbo.ClassTimeTableColumnDetail 
						WHERE ClassTimeTableId=ct.ClassTimeTableId AND TeacherId=@TeacherId)
	AND ct.IsActive=1  AND ct.IsDeleted<>1;

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
