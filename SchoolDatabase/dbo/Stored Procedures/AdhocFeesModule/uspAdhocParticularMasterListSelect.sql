-- =============================================
-- Author:   Meena Kotkar
-- Create date: 26/03/2024
-- Description:  This stored procedure is used to get AdhocParticularMaster  List
-- =============================================
CREATE PROC [dbo].[uspAdhocParticularMasterListSelect](
        @AcademicYearId SMALLINT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
    SELECT 
       a.AdhocParticularMasterId,
	   a.Particular
	   FROM AdhocParticularMaster a 
	   WHERE      
       ISNULL(a.IsDeleted,0)<>1
        
        
  
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