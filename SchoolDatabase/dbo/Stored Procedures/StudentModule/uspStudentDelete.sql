-- =============================================
-- Author:    Meena Kotkar
-- Create date: 4/12/2023
-- Description:  This stored procedure is used delete Student Data
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentDelete](
  @StudentId INT = NULL,
  @AcademicYearId INT,
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
    DECLARE @FeePaymentCount INT;
    SELECT @FeePaymentCount = COUNT(a.AdhocFeePaymentId) 
    FROM [dbo].AdhocFeePayment a
    WHERE a.StudentId=@StudentId AND a.IsDeleted <> 1;

    IF @FeePaymentCount<1
    BEGIN 
            SELECT @FeePaymentCount =@FeePaymentCount+ COUNT(f.FeePaymentId) 
            FROM [dbo].FeePayment f
            WHERE f.StudentId=@StudentId AND  f.IsDeleted <> 1;

            SELECT @FeePaymentCount =@FeePaymentCount+ COUNT(tf.TransportFeePaymentId) 
            FROM [dbo].TransportFeePayment tf
            WHERE tf.ConsumerId=@StudentId AND  tf.RoleId=5 AND tf.IsDeleted <> 1;

            SELECT @FeePaymentCount =@FeePaymentCount+ COUNT(st.StudentKitFeePaymentId) 
            FROM [dbo].StudentKitFeePayment st
            WHERE st.StudentKitFeePaymentId=@StudentId  AND st.IsDeleted <> 1;
    END
  BEGIN TRY
      -- update Statement
      IF @FeePaymentCount<=0
      BEGIN
         UPDATE [dbo].Student 
		    SET IsDeleted=1 , IsAppAccess = 0,
            ModifiedBy=@UserId,
            ModifiedDate=@CurrentDateTime
		    WHERE StudentId=@StudentId
            SELECT 1 AS 'AffectedRows';

		    DELETE FROM [dbo].ParentStudentMapping 
		    WHERE StudentId=@StudentId;
        END
        SELECT 0 AS 'AffectedRows';
    END TRY
    BEGIN CATCH
      -- Log the exception
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
                                 @ErrorState;
    END CATCH
  END