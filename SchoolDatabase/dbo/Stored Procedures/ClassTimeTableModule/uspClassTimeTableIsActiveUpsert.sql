
-- =============================================
-- Author: Abhishek Kumar
-- Create date: 17/01/2023
-- Description: This stored procedure is used for marking class timetable active
-- =============================================
CREATE PROCEDURE [dbo].[uspClassTimeTableIsActiveUpsert]
	@ClassTimeTableId ClassTimeTableMarkActiveType READONLY
AS

BEGIN 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
 
DECLARE @CurrentDateTime DATETIME = GETDATE();


BEGIN TRY 

UPDATE ct SET isActive=tct.IsActive,ModifiedDate=@CurrentDateTime FROM dbo.ClassTimeTable ct JOIN
            @ClassTimeTableId tct ON ct.ClassTimeTableId=tct.ClassTimeTableId;

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