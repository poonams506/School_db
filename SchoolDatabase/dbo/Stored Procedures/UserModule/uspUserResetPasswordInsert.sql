-- =============================================
-- Author:		Abhishek Kumar
-- Create date: 14/04/2023
-- Description:	This stored procedure is used to insert data into UserResetPassword
-- =============================================
CREATE PROCEDURE uspUserResetPasswordInsert (
  @UserId INT
, @Token NVARCHAR(150)
, @ExpirationDate DATETIME)
AS

BEGIN

  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  SET NOCOUNT ON
  BEGIN TRY 

    DECLARE @CurrentDateTime DATETIME= GETDATE();


    INSERT INTO UserResetPassword ([UserId], [Token], [ExpirationDate], [CreatedBy], [CreatedDate])
                VALUES(@UserId,@Token,@ExpirationDate,@UserId,@CurrentDateTime);

  END TRY                                                    
 BEGIN CATCH                         
                                                  
   DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();                                                    
   DECLARE @ErrorSeverity INT = ERROR_SEVERITY();                                                   
   DECLARE @ErrorState INT = ERROR_STATE();                                                       
   DECLARE @ErrorNumber INT = ERROR_NUMBER();                                                  
   DECLARE @ErrorLine INT = ERROR_LINE();                                                 
   DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();                                               
  
   EXEC uspExceptionLogInsert @ErrorLine,@ErrorMessage,@ErrorNumber,@ErrorProcedure,@ErrorSeverity,@ErrorState                                                  
            
 END CATCH   
END