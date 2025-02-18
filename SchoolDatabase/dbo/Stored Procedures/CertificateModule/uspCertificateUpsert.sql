-- =============================================
-- Author:   Meena Kotkar
-- Create date: 29/08/2023
-- Description:  This stored procedure is used to insert Certifcates details
-- =============================================
CREATE PROC uspCertificateUpsert(
	@CertificateAuditsId BIGINT,
	@CertificateTemplateId SMALLINT,
	@StudentId BIGINT,
	@GradeId SMALLINT ,
	@DivisionId SMALLINT,
	@AcademicYearId SMALLINT,
	@IsPublished BIT,
	@Remark NVARCHAR(500),
	@UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();

 BEGIN TRY IF @CertificateAuditsId > 0 BEGIN --Update Statement
	UPDATE 
		CertificateAudits
	SET  
		  [CertificateTemplateId]=@CertificateTemplateId,
		  [StudentId]=@StudentId,
		  [GradeId]=@GradeId,
		  [DivisionId]=@DivisionId,
		  [AcademicYearId]=@AcademicYearId,
		  [IsPublished]=@IsPublished,
		  [Remark]=@Remark,
		  [ModifiedBy] =@UserId, 
		  [ModifiedDate] =@CurrentDateTime
		  
	WHERE CertificateAuditsId = @CertificateAuditsId 
		AND AcademicYearId = @AcademicYearId
	END 
	ELSE
	BEGIN  --INSERT Statement
	INSERT INTO CertificateAudits(
		 [CertificateTemplateId],
		 [StudentId],
		 [GradeId],
		 [DivisionId],
		 [AcademicYearId],
		 [IsPublished],
		 [Remark],
		 [CreatedBy], 
		 [CreatedDate])
	VALUES(
		  @CertificateTemplateId,
		  @StudentId,
		  @GradeId,
		  @DivisionId,
		  @AcademicYearId,
		  @IsPublished,
		  @Remark,
		  @UserId, 
		  @CurrentDateTime
		
	)
  SET @CertificateAuditsId= SCOPE_IDENTITY();
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

