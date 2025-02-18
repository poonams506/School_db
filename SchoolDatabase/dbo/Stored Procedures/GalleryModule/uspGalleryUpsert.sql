-- =============================================
-- Author: Saurabh Walunj 
-- Create date: 05/07/2024
-- Description: This stored procedure is used for doing Gallery Upsert
-- =============================================
CREATE PROCEDURE [dbo].[uspGalleryUpsert]
	@GalleryId BIGINT,
	@GalleryToType INT,
    @AcademicYearId SMALLINT,
    @GalleryTitle NVARCHAR(100),
    @Description NVARCHAR(MAX),
    @StartDate DATETIME,
    @IsPublished BIT,
    @UserId INT,
    @GalleryFileDetails [GalleryFileDetailType] READONLY,
    @GalleryStudentId [SingleIdType] READONLY,
    @GalleryClassId [SingleIdType] READONLY,
    @GalleryTeacherId [SingleIdType] READONLY,
    @GalleryClerkId [SingleIdType] READONLY,
    @GalleryCabDriverId [SingleIdType] READONLY,
	@GalleryMedias [GalleryMediaType] READONLY

AS BEGIN 
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET 
  NOCOUNT ON
  DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
IF @GalleryId > 0  BEGIN -- Update Statement
-- update for Gallery
UPDATE 
    dbo.Gallery
SET 
    
    [Title] = @GalleryTitle,
    [GalleryToType]=@GalleryToType,
    [Description] = @Description,
    [StartDate] = @StartDate,
    [IsPublished] = @IsPublished,
    [ModifiedBy] = @UserId, 
    [ModifiedDate] = @CurrentDateTime 

WHERE 
    [GalleryId] = @GalleryId 

    -- update for Gallerydetails
    DELETE FROM 
    dbo.GalleryDetails 
    WHERE 
    GalleryId = @GalleryId 

    DELETE FROM dbo.GalleryMapping
    WHERE 
	GalleryId = @GalleryId;

	DELETE FROM dbo.GalleryMediaDetails
    WHERE 
    GalleryId = @GalleryId

END
  ELSE
  BEGIN --INSERT Statement
  --insert for Gallery
  INSERT INTO dbo.Gallery 
    (
     [AcademicYearId],[GalleryToType],
     [Title], [Description], [StartDate], [IsPublished],
     [CreatedBy], [CreatedDate]
    )
VALUES 
  (
    @AcademicYearId,@GalleryToType,
    @GalleryTitle,@Description,@StartDate, @IsPublished,
    @UserId, @CurrentDateTime
  )
   SET @GalleryId = SCOPE_IDENTITY();

END  

 -- insert for Gallerydetail
    INSERT INTO dbo.GalleryDetails
	(GalleryId, FileName, FileType, CreatedBy, CreatedDate)
    SELECT @GalleryId, gfd.FileName, gfd.FileType, @UserId, @CurrentDateTime
    FROM
    @GalleryFileDetails AS gfd;

-- insert for NoticeMediaDetails
    INSERT INTO 
    dbo.GalleryMediaDetails(GalleryId,ContentUrl,CreatedBy,CreatedDate)
    SELECT @GalleryId,gmd.ContentUrl,@UserId, @CurrentDateTime
    FROM
   @GalleryMedias AS gmd;

 -- insert  for GalleryMapping
 IF @GalleryToType=1 
 BEGIN
      INSERT INTO dbo.GalleryMapping
	  (GalleryId,StudentId)
      SELECT @GalleryId,Id FROM @GalleryStudentId;
     
 END
 ELSE IF @GalleryToType=2
 BEGIN
       INSERT INTO dbo.GalleryMapping(GalleryId,GradeId,DivisionId)
      SELECT @GalleryId,sgdm.GradeId,sgdm.Divisionid 
	  FROM @GalleryClassId gci JOIN
      dbo.SchoolGradeDivisionMatrix sgdm ON  gci.Id=sgdm.SchoolGradeDivisionMatrixId AND sgdm.AcademicYearId = @AcademicYearId;
 END
 ELSE IF @GalleryToType=3
 BEGIN
       INSERT INTO dbo.GalleryMapping(GalleryId,TeacherId)
      SELECT @GalleryId,Id FROM @GalleryTeacherId;
 END
 ELSE IF @GalleryToType=4
 BEGIN
       INSERT INTO dbo.GalleryMapping(GalleryId,ClerkId)
      SELECT @GalleryId,Id FROM @GalleryClerkId;
 END
 ELSE IF @GalleryToType=5
 BEGIN
       INSERT INTO dbo.GalleryMapping(GalleryId,CabDriverId)
      SELECT @GalleryId,Id FROM @GalleryCabDriverId;
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




