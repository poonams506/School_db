-- =============================================
-- Author:   Prathamesh Ghule
-- Create date: 19/02/2024
-- Description:  This stored procedure is used to Upsert school event  data
-- =============================================
CREATE PROCEDURE uspSchoolEventUpsert
(
    @SchoolEventId SMALLINT,
    @AcademicYearId SMALLINT,
    @EventTitle NVARCHAR (1000),
    @EventDescription NVARCHAR(1000),
    @EventFess MONEY,
    @EventVenue NVARCHAR(1000),
	@EventCoordinator NVARCHAR(1000),
    @StartDate DATETIME,
    @EndDate DATETIME,
    @StartTime DATETIME,
    @EndTime DATETIME,
    @IsCompulsory BIT = 0 ,
    @IsPublished BIT = 0,
    @UserId INT,
    @schoolEventDetails [SchoolEventDetailType] READONLY,
    @ClassId [SingleIdType] READONLY
)
	AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
 
BEGIN TRY
BEGIN TRANSACTION;
IF @SchoolEventId > 0 
BEGIN 
--Update Statement
UPDATE 
 SchoolEvent  
SET 
    
       [EventTitle]   =  @EventTitle,
       [EventDescription]=@EventDescription,
       [EventFess]=@EventFess,
       [EventVenue]=@EventVenue,
       [EventCoordinator]  =  @EventCoordinator,
       [StartDate] = @StartDate,
       [EndDate] = @EndDate, 
       [StartTime]=@StartTime,
       [EndTime]=@EndTime,
       [IsCompulsory] = @IsCompulsory,
       [IsPublished] = @IsPublished,
       [ModifiedBy]=@UserId,
       [ModifiedDate]=@CurrentDateTime
   WHERE 
  [SchoolEventId] = @SchoolEventId
   -- update for SchoolEventdetails
            DELETE FROM dbo.SchoolEventDetails 
            WHERE SchoolEventId = @SchoolEventId;

             DELETE FROM dbo.SchoolEventMapping
    WHERE SchoolEventId=@SchoolEventId;

             -- insert for SchoolEventDetails
            INSERT INTO dbo.SchoolEventDetails(SchoolEventId, FileName, FileType, CreatedBy, CreatedDate)
            SELECT @SchoolEventId, sed.FileName,sed.FileType, @UserId, @CurrentDateTime
            FROM @schoolEventDetails AS sed;

              INSERT INTO dbo.SchoolEventMapping(SchoolEventId,GradeId,DivisionId)
      SELECT @SchoolEventId,sgdm.GradeId,sgdm.Divisionid FROM @ClassId c JOIN
      dbo.SchoolGradeDivisionMatrix sgdm ON  c.Id=sgdm.SchoolGradeDivisionMatrixId and sgdm.AcademicYearId = @AcademicYearId;

  END 
  ELSE 
  BEGIN --INSERT Statement
  INSERT INTO SchoolEvent(
         [AcademicYearId],
         [EventTitle],
         [EventDescription],
         [EventFess],
         [EventVenue],
         [EventCoordinator],
         [StartDate],
         [EndDate],
         [StartTime],
         [EndTime],
         [IsCompulsory],
         [IsPublished],
         [CreatedBy],
         [CreatedDate]
       ) 
    VALUES 
 (
  @AcademicYearId,
  @EventTitle,
  @EventDescription,
  @EventFess,
  @EventVenue,
  @EventCoordinator,
  @StartDate,
  @EndDate,
 @StartTime,
 @EndTime,
  @IsCompulsory,
  @IsPublished,
  @UserId,
  @CurrentDateTime
 )
  SET @SchoolEventId = SCOPE_IDENTITY();

            -- insert for SchoolEventDetails
            INSERT INTO dbo.SchoolEventDetails(SchoolEventId, FileName, FileType, CreatedBy, CreatedDate)
            SELECT @SchoolEventId, sed.FileName,sed.FileType, @UserId, @CurrentDateTime
            FROM @schoolEventDetails AS sed;

              INSERT INTO dbo.SchoolEventMapping(SchoolEventId,GradeId,DivisionId)
      SELECT @SchoolEventId,sgdm.GradeId,sgdm.Divisionid FROM @ClassId c JOIN
      dbo.SchoolGradeDivisionMatrix sgdm ON  c.Id=sgdm.SchoolGradeDivisionMatrixId and sgdm.AcademicYearId = @AcademicYearId;

     

 END 
 COMMIT;
 END TRY 
 BEGIN CATCH
 ROLLBACK;
 DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
 DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
 DECLARE @ErrorState INT = ERROR_STATE();
 DECLARE @ErrorNumber INT = ERROR_NUMBER();
 DECLARE @ErrorLine INT = ERROR_PROCEDURE();
 DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_LINE();
 EXEC uspExceptionLogInsert @ErrorLine, 
 @ErrorMessage, 
 @ErrorNumber, 
 @ErrorProcedure, 
 @ErrorSeverity, 
 @ErrorState;
 THROW;
 END CATCH END
   
