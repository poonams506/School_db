-- =============================================
-- Author:    Meena Kotkar
-- Create date: 15/08/2024  
-- Description:  This stored procedure is used check payment exists for student
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentPaymentExists](
  @StudentId INT ,
  @AcademicYearId INT,
  @IsRTEStudent BIT,
  @UserId INT
) 
AS 
BEGIN 
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
  SET NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
  DECLARE @FeePaymentCount INT;
  DECLARE @CurrentIsRTEStudent BIT;
   
  BEGIN TRY

	  SELECT @CurrentIsRTEStudent =IsRTEStudent
	  FROM [dbo].StudentGradeDivisionMapping
	  WHERE StudentId = @StudentId AND IsDeleted <> 1 ; 

	  IF @CurrentIsRTEStudent = @IsRTEStudent
	  BEGIN
		SELECT 0 AS 'StudentPaymentExist';
	  END
	  ELSE
	  BEGIN
		  SELECT @FeePaymentCount = COUNT(f.FeePaymentId) 
          FROM [dbo].FeePayment f
          WHERE f.StudentId = @StudentId AND f.IsDeleted <> 1;

    
          IF @FeePaymentCount > 0
          BEGIN
              SELECT 1 AS 'StudentPaymentExist';
          END
		  ELSE
          BEGIN
              SELECT 0 AS 'StudentPaymentExist';
          END
		END
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