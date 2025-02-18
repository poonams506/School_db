--===============================================
-- Author:- Gulave Pramod
-- Create date:- 06-08-2024
-- Description:- This stored procedure is used to get StudentEnquiryForm by Delete.
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentEnquiryDelete](
    @StudentEnquiryId INT,
	@UserId INT 
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
  DECLARE @CurrentDateTime DATETIME = GETDATE(); 
  BEGIN TRY

  DECLARE @FeePaymentCount INT=0;
    SELECT @FeePaymentCount = COUNT(a.RegistrationFeeId) 
    FROM RegistrationFee a
    WHERE a.StudentEnquiryId=@StudentEnquiryId AND a.IsDeleted <> 1;
		
		IF @FeePaymentCount>0
		BEGIN
			SELECT 1 AS 'Exist';
		END 
		ELSE
		BEGIN
			 UPDATE StudentEnquiry
				SET IsDeleted=1,
				ModifiedBy=@UserId,
				ModifiedDate=@CurrentDateTime
			WHERE 
				StudentEnquiryId = @StudentEnquiryId
		
			SELECT 0 AS 'Exist';
		END
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
                                 @ErrorState;
    END CATCH
  END