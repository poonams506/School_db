-- =============================================
-- Author: Poonam Bhalke
-- Create date: 08/04/2024
-- Description: This stored procedure is used for doing Survey Upsert
-- =============================================
CREATE PROCEDURE [dbo].[uspSurveyUpsert]
	@SurveyId BIGINT,
    @IsImportant BIT,
    @SurveyToType INT,
    @AcademicYearId SMALLINT,
    @SurveyTitle NVARCHAR(100),
    @SurveyDescription NVARCHAR(MAX),
    @StartDate DATETIME,
    @EndDate DATETIME,
    @IsPublished BIT,
    @UserId INT,
    @ClassTeacherId INT,
    @SurveyFileDetails [SurveyFileDetailType] READONLY,
    @SurveyQuestionDetails [SurveyQuestionType] READONLY,
    @SurveyStudentId [SingleIdType] READONLY,
    @SurveyClassId [SingleIdType] READONLY,
    @SurveyTeacherId [SingleIdType] READONLY,
    @SurveyClerkId [SingleIdType] READONLY,
    @SurveyCabDriverId [SingleIdType] READONLY

AS BEGIN 
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET 
  NOCOUNT ON
  DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
IF @SurveyId > 0  BEGIN -- Update Statement
-- update for Notice
UPDATE 
    dbo.Survey
SET 
    
    [Title] = @SurveyTitle,
    [IsImportant]=@IsImportant,
    [SurveyToType]=@SurveyToType,
    [Description] = @SurveyDescription,
    [StartDate] = @StartDate,
    [EndDate] = @EndDate,
    [IsPublished] = @IsPublished,
    [ModifiedBy] = @UserId, 
    [ModifiedDate] = @CurrentDateTime 

WHERE 
    [SurveyId] = @SurveyId 

    -- update for SurveyDetails
    DELETE FROM 
    dbo.SurveyDetails
    WHERE 
    SurveyId = @SurveyId 

    DELETE FROM dbo.SurveyMapping
    WHERE SurveyId = @SurveyId 

    DELETE FROM 
    dbo.SurveyQuestionDetails
    WHERE 
    SurveyId = @SurveyId 

END
  ELSE
  BEGIN --INSERT Statement
  --insert for Survey
  INSERT INTO dbo.Survey
    (
     [AcademicYearId],[SurveyToType],IsImportant,
     [Title], [Description],  [StartDate], [EndDate], [IsPublished],
     [CreatedBy], [CreatedDate]
    )
VALUES 
  (
    @AcademicYearId,@SurveyToType,@IsImportant,
    @SurveyTitle,@SurveyDescription,@StartDate, @EndDate, @IsPublished,
    @UserId, @CurrentDateTime
  )
   SET @SurveyId = SCOPE_IDENTITY();

END  

 -- insert for SurveyDetails
    INSERT INTO 
    dbo.SurveyDetails(SurveyId,FileName,FileType,CreatedBy,CreatedDate)
    SELECT @SurveyId, sfd.FileName,sfd.FileType,@UserId, @CurrentDateTime
    FROM
    @SurveyFileDetails AS sfd;

-- insert for SurveyQuestionDetails
    INSERT INTO 
    dbo.SurveyQuestionDetails(SurveyId,SurveyQuestions,CreatedBy,CreatedDate)
    SELECT @SurveyId,sqd.SurveyQuestions,@UserId, @CurrentDateTime
    FROM
    @SurveyQuestionDetails AS sqd;

 -- insert  for SurveyMapping
 IF @SurveyToType=1 
 BEGIN
      INSERT INTO dbo.SurveyMapping(SurveyId,StudentId)
      SELECT @SurveyId,Id FROM @SurveyStudentId;
     
 END
 ELSE IF @SurveyToType=2
 BEGIN
       INSERT INTO dbo.SurveyMapping(SurveyId,GradeId,DivisionId)
      SELECT @SurveyId,sgdm.GradeId,sgdm.Divisionid FROM @SurveyClassId nc JOIN
      dbo.SchoolGradeDivisionMatrix sgdm ON  nc.Id=sgdm.SchoolGradeDivisionMatrixId AND sgdm.AcademicYearId = @AcademicYearId;
 END
 ELSE IF @SurveyToType=3
 BEGIN
       INSERT INTO dbo.SurveyMapping(SurveyId,TeacherId)
      SELECT @SurveyId,Id FROM @SurveyTeacherId;
 END
 ELSE IF @SurveyToType=4
 BEGIN
       INSERT INTO dbo.SurveyMapping(SurveyId,ClerkId)
      SELECT @SurveyId,Id FROM @SurveyClerkId;
 END
 ELSE IF @SurveyToType=5
 BEGIN
       INSERT INTO dbo.SurveyMapping(SurveyId,CabDriverId)
      SELECT @SurveyId,Id FROM @SurveyCabDriverId;
 END
 ELSE IF @SurveyToType=6
  BEGIN
       INSERT INTO dbo.SurveyMapping(SurveyId,ClassTeacherId, StudentId)
       SELECT @SurveyId,@ClassTeacherId ,ssd.Id 
       FROM 
         @SurveyStudentId AS ssd;
 END

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

