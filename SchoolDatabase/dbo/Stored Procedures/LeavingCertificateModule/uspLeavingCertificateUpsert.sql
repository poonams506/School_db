-- =============================================
-- Author:   Deepak W
-- Create date: 01/01/2024
-- Description:  This stored procedure is used to insert Leaving Certifcates details
-- =============================================
CREATE PROCEDURE [dbo].[uspLeavingCertificateUpsert]
(
	@StudentId BIGINT,
	@GradeId SMALLINT ,
	@DivisionId SMALLINT,
	@StatusId SMALLINT,
	@Remark NVARCHAR(500),
	@Progress NVARCHAR(200),
	@Conduct NVARCHAR(200),
	@DateOfLeavingTheSchool DATE,
	@StdInWhichStudyingAndSinceWhenInWordsAndFigures NVARCHAR(200),
	@ReasonOfLeavingSchool NVARCHAR(300),
	@DateSignCurrent DATE,
	@UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
  DECLARE @LeavingCertificateAuditsId INT, @SerialNumber INT;
  BEGIN TRY 
    
    INSERT INTO LeavingCertificateAudits(
		 [StudentId],
		 [GradeId],
		 [DivisionId],
		 [StatusId],
		 [Remark],
		 [Progress],
		  [Conduct],
		  [DateOfLeavingTheSchool],
		  [StdInWhichStudyingAndSinceWhenInWordsAndFigures],
		  [ReasonOfLeavingSchool],
		  [DateSignCurrent],
		 [CreatedBy], 
		 [CreatedDate])
	VALUES(
		  @StudentId,
		  @GradeId,
		  @DivisionId,
		  @StatusId,
		  @Remark,
		  @Progress,
		  @Conduct,
		  @DateOfLeavingTheSchool,
		  @StdInWhichStudyingAndSinceWhenInWordsAndFigures,
		  @ReasonOfLeavingSchool,
		  @DateSignCurrent,
		  @UserId, 
		  @CurrentDateTime
		
	)
  SET @LeavingCertificateAuditsId = SCOPE_IDENTITY();
	
   DECLARE @SerialNoStartNumber INT = (SELECT SerialNoStartNumber FROM School);
   IF @SerialNoStartNumber > 0
   BEGIN
        SET @SerialNoStartNumber = @SerialNoStartNumber - 1;
   END

   SET @SerialNumber = (ISNULL(@SerialNoStartNumber,0) + @LeavingCertificateAuditsId);
   -- update Serial number in main table
   UPDATE LeavingCertificateAudits 
   SET SerialNumber = @SerialNumber,
	   ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
	WHERE LeavingCertificateAuditsId = @LeavingCertificateAuditsId AND IsDeleted <> 1;

   

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