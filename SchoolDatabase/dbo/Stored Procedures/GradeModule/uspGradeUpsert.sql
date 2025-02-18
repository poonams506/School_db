-- =============================================
-- Author:    Swapnil Bhaskar
-- Create date: 13/08/2023
-- Description:  This stored procedure is used insert Grade data
-- =============================================
CREATE PROCEDURE uspGradeUpsert (
  @GradeId INT = NULL, 
  @GradeName NVARCHAR(50),
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
IF @GradeId > 0 
	BEGIN 
	IF NOT EXISTS (SELECT 1 FROM Grade WHERE [GradeName] = @GradeName And IsDeleted=0) 
	BEGIN 
		UPDATE 
		Grade 
		SET 
			[GradeName] = @GradeName, 
			[ModifiedBy] = @UserId, 
			[ModifiedDate] = @CurrentDateTime 
		WHERE 
		 [GradeId] = @GradeId
		select 0 as Exits;
	END 
	ELSE IF EXISTS (SELECT 1 FROM Grade WHERE [GradeId] = @GradeId AND [GradeName] = @GradeName And IsDeleted=0) 
	BEGIN 
		UPDATE 
		Grade 
		SET 
			[GradeName] = @GradeName, 
			[ModifiedBy] = @UserId, 
			[ModifiedDate] = @CurrentDateTime 
		WHERE 
		 [GradeId] = @GradeId
		select 0 as Exits;
	END 
	ELSE
      BEGIN
        select 1 as Exits
      END
  END

  ELSE
  
  BEGIN   
  IF NOT EXISTS (SELECT 1 FROM Grade WHERE [GradeName] = @GradeName And IsDeleted=0)
      BEGIN
        -- Insert Statement
        INSERT INTO Grade ([GradeName], [CreatedBy], [CreatedDate]) 
        VALUES (@GradeName, @UserId, @CurrentDateTime)
		select 0 as Exits
      END
      ELSE
      BEGIN
        select 1 as Exits
      END

END   
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
@ErrorState END CATCH END

