-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 25/09/2023
-- Description:  This stored procedure is used to insert FeeWavierType
-- =============================================
CREATE PROCEDURE [dbo].[uspFeeWavierTypesUpsert]
	(@FeeWavierTypeId BIGINT,
	@AcademicYearId SMALLINT,
	@FeeWavierTypeName NVARCHAR(100),
	@FeeWavierTypeDisplayName NVARCHAR(100),
	@Description NVARCHAR(500),
	@CategoryId SMALLINT,
	@NumberOfInstallments SMALLINT,
	@DiscountInPercent NUMERIC(5,4),
	@LatePerDayFeeInPercent NUMERIC(5,4),
	@IsActive BIT = 0,
    @UserId INT,
	@FeeWavierTypesInstallmentsDetailsType dbo.FeeWavierTypesInstallmentsDetailsType READONLY)
 AS BEGIN 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET NOCOUNT ON 

DECLARE @CurrentDateTime DATETIME = GETDATE();
DECLARE @CanInsertedOrUpdated BIT=1;
DECLARE @InsertedId TABLE(Id BIGINT NOT NULL)
BEGIN TRY 

     IF @FeeWavierTypeId > 0
	 BEGIN
     MERGE INTO dbo.FeeWavierTypesInstallmentsDetails AS Target
	 USING @FeeWavierTypesInstallmentsDetailsType AS Source 
	 ON Source.FeeWavierTypesInstallmentsDetailsTypeId=Target.FeeWavierTypesInstallmentsDetailsId
	 WHEN MATCHED THEN
	 UPDATE SET Target.LateFeeStartDate = Source.LateFeeStartDate,
	 Target.DiscountEndDate = Source.DiscountEndDate, Target.ModifiedBy= @UserId, Target.ModifiedDate = @CurrentDateTime
	 WHEN NOT MATCHED THEN
	 INSERT(FeeWavierTypeId,AcademicYearId , LateFeeStartDate, 
      DiscountEndDate, CreatedBy, CreatedDate) VALUES(@FeeWavierTypeId,@AcademicYearId,Source.LateFeeStartDate, Source.DiscountEndDate, @UserId, @CurrentDateTime);
	 END

IF @CanInsertedOrUpdated=1 AND EXISTS(SELECT FeeWavierTypeId FROM dbo.FeeWavierTypes 
                               WHERE FeeWavierTypeName = @FeeWavierTypeName AND 
							   FeeWavierTypeId<>@FeeWavierTypeId AND IsDeleted=0)
BEGIN
	SET @CanInsertedOrUpdated=0;
	SELECT 101 AS StatusCode,@FeeWavierTypeId AS Id;
END
ELSE IF @FeeWavierTypeId > 0
BEGIN
     UPDATE dbo.FeeWavierTypes SET FeeWavierDisplayName = @FeeWavierTypeDisplayName , FeeWavierTypeName = @FeeWavierTypeName, Description = @Description,
	 ModifiedBy=@UserId,
	 ModifiedDate=@CurrentDateTime
	 WHERE FeeWavierTypeId=@FeeWavierTypeId
END

IF @CanInsertedOrUpdated=1 AND EXISTS(SELECT TOP (1) fpawp.FeePaymentAppliedWavierMappingId 
                     FROM dbo.FeePaymentAppliedWavierMapping fpawp 
     INNER JOIN dbo.FeeParticularWavierMapping fpwp 
     ON fpawp.FeeParticularWavierMappingId = fpwp.FeeParticularWavierMappingId
     WHERE fpwp.FeeWavierTypeId = @FeeWavierTypeId AND fpawp.AcademicYearId=@AcademicYearId
	 ORDER BY fpawp.FeePaymentAppliedWavierMappingId  DESC)
BEGIN
	SET @CanInsertedOrUpdated=0;
	SELECT 102 AS StatusCode,@FeeWavierTypeId AS Id;
END

IF @CanInsertedOrUpdated=1 
BEGIN
     
	 MERGE INTO dbo.FeeWavierTypes AS target
	 USING (SELECT @FeeWavierTypeId,@AcademicYearId,@FeeWavierTypeName,
	@FeeWavierTypeDisplayName,@Description,@CategoryId,
	@NumberOfInstallments,@DiscountInPercent,@LatePerDayFeeInPercent,@IsActive,@UserId 
	) AS source (FeeWavierTypeId,AcademicYearId,FeeWavierTypeName,
	FeeWavierTypeDisplayName,Description,CategoryId,NumberOfInstallments,DiscountInPercent,LatePerDayFeeInPercent,
	IsActive,UserId )
	ON target.FeeWavierTypeId=source.FeeWavierTypeId AND source.FeeWavierTypeId<>0
	WHEN MATCHED THEN UPDATE SET 
	target.FeeWavierTypeName=source.FeeWavierTypeName,
	target.FeeWavierDisplayName=source.FeeWavierTypeDisplayName,
	target.Description=source.Description,
	target.CategoryId=source.CategoryId,
	target.NumberOfInstallments=source.NumberOfInstallments,
	target.DiscountInPercent = source.DiscountInPercent,
	target.LatePerDayFeeInPercent=source.LatePerDayFeeInPercent,
	target.IsActive=source.IsActive
	WHEN NOT MATCHED THEN
    INSERT(AcademicYearId,FeeWavierTypeName,FeeWavierDisplayName,Description,CategoryId,NumberOfInstallments,DiscountInPercent,LatePerDayFeeInPercent,
	IsActive)
	VALUES(AcademicYearId,FeeWavierTypeName,FeeWavierTypeDisplayName,Description,CategoryId,NumberOfInstallments,DiscountInPercent,LatePerDayFeeInPercent,
	IsActive)
	OUTPUT Inserted.FeeWavierTypeId INTO @InsertedId;

	IF @FeeWavierTypeId = 0 OR @FeeWavierTypeId IS NULL
	BEGIN
	    SELECT @FeeWavierTypeId = Id FROM @InsertedId;
	END
	
	MERGE INTO dbo.FeeWavierTypesInstallmentsDetails AS Target
	 USING @FeeWavierTypesInstallmentsDetailsType AS Source 
	 ON Source.FeeWavierTypesInstallmentsDetailsTypeId=Target.FeeWavierTypesInstallmentsDetailsId
	 WHEN MATCHED THEN
	 UPDATE SET Target.LateFeeStartDate = Source.LateFeeStartDate,
	 Target.DiscountEndDate = Source.DiscountEndDate, Target.ModifiedBy= @UserId, Target.ModifiedDate = @CurrentDateTime
	 WHEN NOT MATCHED THEN
	 INSERT(FeeWavierTypeId,AcademicYearId , LateFeeStartDate, 
      DiscountEndDate, CreatedBy, CreatedDate) VALUES(@FeeWavierTypeId,@AcademicYearId,Source.LateFeeStartDate, Source.DiscountEndDate, @UserId, @CurrentDateTime);
				 

	SELECT 200 AS StatusCode,Id FROM @InsertedId;
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