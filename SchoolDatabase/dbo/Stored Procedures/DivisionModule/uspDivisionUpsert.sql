-- =============================================
-- Author:    Swapnil Bhaskar
-- Create date: 13/08/2023
-- Description:  This stored procedure is used insert Division data
-- =============================================
CREATE PROCEDURE uspDivisionUpsert (
  @DivisionId INT = NULL, 
  @DivisionName NVARCHAR(50),
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY IF @DivisionId > 0 
	BEGIN 
	IF NOT EXISTS (SELECT 1 FROM Division WHERE [DivisionName] = @DivisionName And IsDeleted=0) 
	BEGIN 
		UPDATE 
		 Division
		SET 
		 [DivisionName] = @DivisionName, 
		 [ModifiedBy] = @UserId, 
		[ModifiedDate] = @CurrentDateTime 
		WHERE 
		 [DivisionId] = @DivisionId
		SELECT 0 as Exits;
	END 
	ELSE IF EXISTS (SELECT 1 FROM Division WHERE [DivisionId] = @DivisionId AND [DivisionName] = @DivisionName And IsDeleted=0) 
	BEGIN 
		UPDATE 
		Division
		SET 
		[DivisionName] = @DivisionName, 
		[ModifiedBy] = @UserId, 
		[ModifiedDate] = @CurrentDateTime 
		WHERE 
		 [DivisionId] = @DivisionId
		SELECT 0 as Exits;
	END 
	ELSE
      BEGIN
        SELECT 1 as Exits
      END
  END

  ELSE
  
  BEGIN --INSERT Statement
  IF NOT EXISTS (SELECT 1 FROM Division WHERE [DivisionName] = @DivisionName And IsDeleted=0)
  BEGIN
  INSERT INTO Division(
    [DivisionName], [CreatedBy], 
    [CreatedDate]
	) 
	VALUES 
	(
    @DivisionName,
    @UserId, @CurrentDateTime
	)
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
