﻿-- =============================================
-- Author:    Prerana Aher
-- Create date: 08/08/2024
-- Description:  This stored procedure is used delete Registration Fee Data
-- =============================================
CREATE PROCEDURE [dbo].[uspRegistrationFeeDelete](
   @RegistrationFeeId INT = NULL,
   @UserId INT
) 
AS BEGIN 
SET 
TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
NOCOUNT ON 
DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY
    -- Soft delete RegistrationFee
    UPDATE RegistrationFee 
    SET IsDeleted = 1,
    ModifiedBy = @UserId,
    ModifiedDate = @CurrentDateTime
	WHERE RegistrationFeeId = @RegistrationFeeId;

    -- Soft delete associated RegistrationFeeDetails
    UPDATE RegistrationFeeDetails 
    SET IsDeleted = 1,
    ModifiedBy = @UserId,
    ModifiedDate = @CurrentDateTime 
	WHERE RegistrationFeeId = @RegistrationFeeId;
              
END TRY
BEGIN CATCH
-- Log the exception
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



