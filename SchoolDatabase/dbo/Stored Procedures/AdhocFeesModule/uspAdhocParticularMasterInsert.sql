-- =============================================
-- Author:   Meena Kotkar
-- Create date: 26/03/2024
-- Description:  This stored procedure is used to get AdhocParticularMaster insert  particular
-- =============================================
CREATE PROC [dbo].[uspAdhocParticularMasterInsert](
      @AdhocParticularMasterId INT=NULL,
	  @Particular NVARCHAR(100),
	  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
   DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
 
  IF NOT EXISTS (SELECT 1 FROM AdhocParticularMaster WHERE Particular = @Particular And IsDeleted=0)
      BEGIN
        -- Insert Statement
        INSERT INTO AdhocParticularMaster (Particular, [CreatedBy], [CreatedDate]) 
        VALUES (@Particular, @UserId, @CurrentDateTime)
		select 0 as Exits
      END
      ELSE
      BEGIN
        select 1 as Exits
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
@ErrorState END CATCH End