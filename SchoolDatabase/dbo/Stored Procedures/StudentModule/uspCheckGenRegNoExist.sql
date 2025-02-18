-- =============================================
-- Author:    Meena Kotkar
-- Create date: 29/05/2024
-- Description:  This stored procedure is check student GenRegNO is exist or not
-- =============================================
CREATE PROCEDURE [dbo].[uspCheckGenRegNoExist](
  @StudentId BIGINT,
   @GeneralRegistrationNo NVARCHAR(100)
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

   BEGIN TRY 
		IF EXISTS (
        SELECT 1 
        FROM dbo.Student
        WHERE GeneralRegistrationNo = @GeneralRegistrationNo
        AND IsDeleted <> 1
        AND (StudentId <> @StudentId OR @StudentId IS NULL)
    )
    BEGIN
        SELECT 1 AS 'GeneralRegistrationNoAvailable';
    END
    ELSE 
    BEGIN
              SELECT 0 AS 'GeneralRegistrationNoAvailable';
    END
  END TRY

BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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