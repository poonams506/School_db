CREATE PROCEDURE [dbo].[uspTransportConsumerMappingDelete](
 @TransportConsumerStoppageMappingId INT,
 @RoleId INT,
 @AcademicYearId INT,
 @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON
  
  DECLARE @CurrentDateTime DATETIME = GETDATE();
   DECLARE @Count INT;

    SELECT @Count = COUNT(TransportFeePaymentId)
	FROM TransportFeePayment 
    WHERE TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId AND RoleId = @RoleId AND AcademicYearId=@AcademicYearId AND IsDeleted<>1;
	
	IF @Count = 0
	BEGIN
BEGIN TRY 
	
	UPDATE dbo.TransportConsumerStoppageMapping 
	       SET IsDeleted=1,ModifiedDate=@CurrentDateTime,ModifiedBy=@UserId
	       WHERE TransportConsumerStoppageMappingId=@TransportConsumerStoppageMappingId;
		   SELECT 1 AS 'AffectedRows';
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
ELSE
  BEGIN
    -- Return 0 if the Grade does not exist
    SELECT 0 AS 'AffectedRows';
  END
 END