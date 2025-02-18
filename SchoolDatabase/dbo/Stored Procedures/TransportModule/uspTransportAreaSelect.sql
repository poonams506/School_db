-- =============================================
-- Author:    Meena Kotkar
-- Create date: 09/04/2024
-- Description:  This stored procedure is used to get area info
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportAreaSelect](
    @AreaId INT,
    @AcademicYearId SMALLINT) AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY                  
 SELECT 
  A.AreaId,
  A.AreaName,
  A.PickPrice,
  A.DropPrice,
  A.PickAndDropPrice,
  A.Description,
  A.AcademicYearId
  FROM TransportArea A
  WHERE A.AreaId=@AreaId AND A.AcademicYearId=@AcademicYearId
   AND ISNULL(A.IsDeleted,0)<>1 
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