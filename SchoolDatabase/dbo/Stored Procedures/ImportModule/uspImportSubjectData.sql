--===============================================
-- Author:    Meena Kotkar
-- Create date: 7/3/2024
-- Description:  This stored procedure is used Import Teacher Data
-- =============================================
CREATE PROCEDURE [dbo].[uspImportSubjectData](
  @SubjectImportType SubjectImportType READONLY,
  @UserId INT,
  @schoolCode NVARCHAR(20)
) AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE(); 
  
  BEGIN TRY 
    MERGE dbo.SubjectMaster AS Target
	USING (SELECT  ST.Subject_Name
	   FROM  @SubjectImportType ST
		) As Source ON Target.SubjectName =Source.Subject_Name AND
		 ISNULL(Target.IsDeleted,0)=0
		WHEN NOT MATCHED BY Target THEN 
		 INSERT(SubjectName,CreatedBy,CreatedDate) 
       Values(Source.Subject_Name,@UserId,@CurrentDateTime) 
	 
     WHEN MATCHED THEN UPDATE SET
         Target.SubjectName = Source.Subject_Name, 
         Target.ModifiedBy = @UserId, 
         Target.ModifiedDate = @CurrentDateTime;



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