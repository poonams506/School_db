-- =============================================
-- Author:    Poonam Bahlke
-- Create date: 08/04/2024
-- Description:  This stored procedure is used to Get Roles List for Survey Field in Filter
-- =============================================
CREATE PROC dbo.uspSurveyFromRoleAppSelect
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY

SELECT RoleId AS Id, [Name] AS [Value],RoleKey AS [Key] 
FROM [dbo].[Role] r WHERE r.RoleId IN(2,3,4,7)
ORDER BY R.[Name];

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
GO

