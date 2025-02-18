
-- =============================================
-- Author: Abhishek Kumar
-- Create date: 02/01/2023
-- Description: This stored procedure is used for doing Class Timetable Upsert
-- =============================================
CREATE PROCEDURE [dbo].[uspClassTimeTableUpsert]
	@ClassTimeTableId INT,
    @ClassId INT,
    @ClassTimeTableName NVARCHAR(150),
    @TimeTableRowDetail [ClassTimeTableRowDetailType] READONLY,
    @TimeTableColumnDetail [ClassTimeTableColumnDetailType] READONLY,
    @AcademicYearId INT,
    @UserId INT
   

AS BEGIN 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
  DECLARE @CurrentDateTime DATETIME = GETDATE();


  DECLARE @GradeId INT;
  DECLARE @DivisionId INT;

  SELECT TOP (1) @GradeId=sgdm.GradeId,@DivisionId=sgdm.DivisionId FROM
  dbo.SchoolGradeDivisionMatrix sgdm WHERE  sgdm.SchoolGradeDivisionMatrixId=@ClassId and sgdm.AcademicYearId = @AcademicYearId and sgdm.IsDeleted <>1
  ORDER BY sgdm.SchoolGradeDivisionMatrixId DESC;

BEGIN TRY 



IF @ClassTimeTableId > 0  
BEGIN

-- update for ClassTimeTable
UPDATE 
    dbo.ClassTimeTable
SET 
    
    [GradeId]=@GradeId,
    [DivisionId]=@DivisionId,
    [ClassTimeTableName]=@ClassTimeTableName,
    [ModifiedBy] = @UserId, 
    [ModifiedDate] = @CurrentDateTime 

WHERE 
    [ClassTimeTableId] = @ClassTimeTableId 

    DELETE FROM dbo.ClassTimeTableColumnDetail WHERE ClassTimeTableId=@ClassTimeTableId;

    DELETE FROM dbo.ClassTimeTableRowDetail WHERE ClassTimeTableId=@ClassTimeTableId;

END
  ELSE
  BEGIN 
  --insert for ClassTimeTable
  INSERT INTO dbo.ClassTimeTable 
    (
     [ClassTimeTableName],[GradeId],[DivisionId],[AcademicYearId],
     [CreatedBy], [CreatedDate]
    )
VALUES 
  (
    @ClassTimeTableName,@GradeId,@DivisionId,
    @AcademicYearId,@UserId, @CurrentDateTime
  )
   SET @ClassTimeTableId = SCOPE_IDENTITY();

END  

   DECLARE @InsertedId TABLE(Id INT,SequenceId INT);

 -- insert for ClassTimeTableRowDetail
    INSERT INTO 
    dbo.ClassTimeTableRowDetail(ClassTimeTableId,PeriodTypeId,StartingHour,StartingMinute,
                                EndingHour,EndingMinute,SequenceId,CreatedBy, CreatedDate)
                    OUTPUT INSERTED.ClassTimeTableRowDetailId,INSERTED.SequenceId INTO @InsertedId
    SELECT @ClassTimeTableId, crow.PeriodTypeId,crow.StartingHour,crow.StartingMinute,
                                crow.EndingHour,crow.EndingMinute,crow.SequenceId, @UserId, @CurrentDateTime
    FROM
    @TimeTableRowDetail AS crow;

 -- insert for ClassTimeTableColumnDetail
    INSERT INTO 
    dbo.ClassTimeTableColumnDetail(ClassTimeTableId,ClassTimeTableRowDetailId,DayNo,SubjectId,TeacherId,CreatedBy, CreatedDate)
    SELECT @ClassTimeTableId,inserted_row.Id,crow.[Day],crow.SubjectId,crow.TeacherId, @UserId, @CurrentDateTime
    FROM
    @TimeTableColumnDetail AS crow JOIN 
    @InsertedId inserted_row ON crow.SequenceId=inserted_row.SequenceId;

    SELECT 1;


END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
@ErrorState END CATCH END