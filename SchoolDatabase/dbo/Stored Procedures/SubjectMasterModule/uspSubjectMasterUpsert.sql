-- =============================================
-- Author:    Chaitanya KAsar
-- Create date: 01/03/2024
-- Description:  This stored procedure is used insert Subject Master data
-- =============================================
CREATE PROCEDURE uspSubjectMasterUpsert (
  @SubjectMasterId INT, 
  @SubjectName NVARCHAR(50),
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
IF EXISTS (SELECT TOP (1) SubjectMasterId  FROM dbo.SubjectMaster  
			WHERE SubjectMasterId<>@SubjectMasterId AND 
			SubjectName=@SubjectName AND
			IsDeleted=0 ORDER BY SubjectName)
	BEGIN
		SELECT -1;
	END
	ELSE
    BEGIN
		IF @SubjectMasterId > 0 
	BEGIN 
		--Update Statement
		UPDATE 
		dbo.SubjectMaster 
		SET 
			[SubjectName] = @SubjectName, 
			[ModifiedBy] = @UserId, 
			[ModifiedDate] = @CurrentDateTime 
		WHERE 
		 [SubjectMasterId] = @SubjectMasterId
    END

  ELSE
  
  BEGIN   
         -- Insert Statement
        INSERT INTO dbo.SubjectMaster([SubjectName], [CreatedBy], [CreatedDate]) 
        VALUES (@SubjectName, @UserId, @CurrentDateTime)
  END   
  SELECT 1;
 END


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
@ErrorState END CATCH END

