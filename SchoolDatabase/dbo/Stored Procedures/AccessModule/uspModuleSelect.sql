-- =============================================
-- Author:    Deepak Walunj
-- Create date: 20/08/2023
-- Description:  This stored procedure is used to get roles
-- =============================================
CREATE PROCEDURE [dbo].[uspModuleSelect]
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

DECLARE @temp TABLE(
ModuleId INT,
CustSort INT,
ModuleName NVARCHAR(100),
ModuleKey NVARCHAR(100),
MenuUrl NVARCHAR(500)
)

INSERT INTO @temp
SELECT
  ModuleId,	
  coalesce(ParentId,ModuleId) as CustSort,
  Name AS 'ModuleName',
  ModuleKey AS 'ModuleKey',
  MenuUrl
FROM 
  Module 
WHERE 
  IsDeleted<>1  

SELECT ModuleId,	
       ModuleName,
       ModuleKey,
       MenuUrl
FROM @temp 
ORDER BY CustSort,MenuUrl

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

