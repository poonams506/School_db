-- =============================================
-- Author:    Shambala Apugade
-- Create date: 19/06/2024
-- Description:  This stored procedure is used to get shared transport school info 
-- =============================================
CREATE PROCEDURE [dbo].[uspSharedTransportSchoolSelect](
@SchoolCode NVARCHAR(250)) 
AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY 

DECLARE @Guid uniqueidentifier
SELECT @Guid = [Guid] FROM SharedTransportSchool WHERE Schoolcode= @SchoolCode

SELECT s.SchoolCode 
FROM SharedTransportSchool s 
WHERE [Guid] = @Guid AND IsDeleted<>1;

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