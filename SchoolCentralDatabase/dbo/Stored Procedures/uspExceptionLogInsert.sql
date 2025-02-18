-- =============================================
-- Author:		Abhishek Kumar
-- Create date: 27/03/2023
-- Description:	This stored procedure is used to log exception log
-- =============================================
CREATE PROCEDURE uspExceptionLogInsert (@ErrorLine INT
, @ErrorMessage NVARCHAR(MAX)
, @ErrorNumber INT
, @ErrorProcedure NVARCHAR(1000)
, @ErrorSeverity INT
, @ErrorState INT)
AS

BEGIN

  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  SET NOCOUNT ON


    DECLARE @CurrentDateTime DATETIME= GETDATE();


    INSERT INTO ExceptionLog ([ErrorLine], [ErrorMessage], [ErrorNumber], [ErrorProcedure], [ErrorSeverity], [ErrorState], [ErrorRaisedDate])
      SELECT
        @ErrorLine,
        @ErrorMessage,
        @ErrorNumber,
        @ErrorProcedure,
        @ErrorSeverity,
        @ErrorState,
        @CurrentDateTime AS DateErrorRaised

  
END