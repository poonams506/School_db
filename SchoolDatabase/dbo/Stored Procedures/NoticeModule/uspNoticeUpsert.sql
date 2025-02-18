-- =============================================
-- Author: Poonam Bhalke
-- Create date: 28/08/2023
-- Description: This stored procedure is used for doing Notice Upsert
-- =============================================
CREATE PROCEDURE [dbo].[uspNoticeUpsert]
	@NoticeId BIGINT,
    @IsImportant BIT,
    @NoticeToType INT,
    @AcademicYearId SMALLINT,
    @NoticeTitle NVARCHAR(100),
    @NoticeDescription NVARCHAR(MAX),
    @StartDate DATETIME,
    @EndDate DATETIME,
    @IsPublished BIT,
    @UserId INT,
    @NoticeFileDetails [NoticeFileDetailType] READONLY,
    @NoticeStudentId [SingleIdType] READONLY,
    @NoticeClassId [SingleIdType] READONLY,
    @NoticeTeacherId [SingleIdType] READONLY,
    @NoticeClerkId [SingleIdType] READONLY,
    @NoticeCabDriverId [SingleIdType] READONLY,
    @Mediadetails [MediaType] READONLY

AS BEGIN 
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET 
  NOCOUNT ON
  DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
IF @NoticeId > 0  BEGIN -- Update Statement
-- update for Notice
UPDATE 
    dbo.Notice
SET 
    
    [Title] = @NoticeTitle,
    [IsImportant]=@IsImportant,
    [NoticeToType]=@NoticeToType,
    [Description] = @NoticeDescription,
    [StartDate] = @StartDate,
    [EndDate] = @EndDate,
    [IsPublished] = @IsPublished,
    [ModifiedBy] = @UserId, 
    [ModifiedDate] = @CurrentDateTime 

WHERE 
    [NoticeId] = @NoticeId 

    -- update for Noticedetails
    DELETE FROM 
    dbo.NoticeDetails 
    WHERE 
    NoticeId = @NoticeId 

    DELETE FROM dbo.NoticeMapping
    WHERE NoticeId=@NoticeId;

    DELETE FROM dbo.NoticeMediaDetails
    WHERE 
    NoticeId = @NoticeId 

END
  ELSE
  BEGIN --INSERT Statement
  --insert for Notice
  INSERT INTO dbo.Notice 
    (
     [AcademicYearId],[NoticeToType],IsImportant,
     [Title], [Description],  [StartDate], [EndDate], [IsPublished],
     [CreatedBy], [CreatedDate]
    )
VALUES 
  (
    @AcademicYearId,@NoticeToType,@IsImportant,
    @NoticeTitle,@NoticeDescription,@StartDate, @EndDate, @IsPublished,
    @UserId, @CurrentDateTime
  )
   SET @NoticeId = SCOPE_IDENTITY();

END  

 -- insert for Noticedetail
    INSERT INTO 
    dbo.NoticeDetails(NoticeId,FileName,FileType, CreatedBy, CreatedDate)
    SELECT @NoticeId, hwt.FileName,hwt.FileType, @UserId, @CurrentDateTime
    FROM
    @NoticeFileDetails AS hwt;


-- insert for NoticeMediaDetails
    INSERT INTO 
    dbo.NoticeMediaDetails(NoticeId,ContentUrl,CreatedBy,CreatedDate)
    SELECT @NoticeId,md.ContentUrl,@UserId, @CurrentDateTime
    FROM
   @Mediadetails AS md;

 -- insert  for NoticeMapping
 IF @NoticeToType=1 
 BEGIN
      INSERT INTO dbo.NoticeMapping(NoticeId,StudentId)
      SELECT @NoticeId,Id FROM @NoticeStudentId;
     
 END
 ELSE IF @NoticeToType=2
 BEGIN
       INSERT INTO dbo.NoticeMapping(NoticeId,GradeId,DivisionId)
      SELECT @NoticeId,sgdm.GradeId,sgdm.Divisionid FROM @NoticeClassId nc JOIN
      dbo.SchoolGradeDivisionMatrix sgdm ON  nc.Id=sgdm.SchoolGradeDivisionMatrixId AND sgdm.AcademicYearId = @AcademicYearId;
 END
 ELSE IF @NoticeToType=3
 BEGIN
       INSERT INTO dbo.NoticeMapping(NoticeId,TeacherId)
      SELECT @NoticeId,Id FROM @NoticeTeacherId;
 END
 ELSE IF @NoticeToType=4
 BEGIN
       INSERT INTO dbo.NoticeMapping(NoticeId,ClerkId)
      SELECT @NoticeId,Id FROM @NoticeClerkId;
 END
 ELSE IF @NoticeToType=5
 BEGIN
       INSERT INTO dbo.NoticeMapping(NoticeId,CabDriverId)
      SELECT @NoticeId,Id FROM @NoticeCabDriverId;
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