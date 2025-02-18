-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 04/03/2024
-- Description:  This stored procedure is used delete Subject master data
-- =============================================
CREATE PROCEDURE [dbo].[uspSubjectMasterDelete](
  @SubjectMasterId  INT,
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
  BEGIN TRY
  DECLARE @CurrentDateTime DATETIME = GETDATE();

  UPDATE dbo.SubjectMaster SET IsDeleted=1,
        ModifiedBy=@UserId,
       ModifiedDate=@CurrentDateTime
        WHERE SubjectMasterId=@SubjectMasterId;

  SELECT 1 as 'AffectedRows';
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
@ErrorState END CATCH End

