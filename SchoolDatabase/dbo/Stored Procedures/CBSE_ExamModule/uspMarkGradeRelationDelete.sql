--===============================================
-- Author:- Tejas Rahane
-- Create date:- 25-07-2024
-- Description:- Delete Procedure for MarksGradeRelation
-- =============================================
CREATE PROCEDURE [dbo].[uspCBSE_MarksGradeRelationDelete] (
    @MarksGradeRelationId BIGINT,
    @UserId INT = NULL
) 
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @CurrentDateTime DATETIME = GETDATE();
	 DECLARE @MarksGradeCount INT;

	 
    SELECT @MarksGradeCount = COUNT(MarksGradeRelationId)
	FROM CBSE_MarksGradeRelation mg
	inner join CBSE_ExamResult er on mg.Grade = er.Grade
	WHERE MarksGradeRelationId = @MarksGradeRelationId 
	and mg.IsDeleted <> 1
	and er.IsDeleted <> 1

	IF @MarksGradeCount = 0
BEGIN
    BEGIN TRY
        UPDATE CBSE_MarksGradeRelation
        SET IsDeleted = 1,
            ModifiedBy = @UserId,
            ModifiedDate = @CurrentDateTime
        WHERE MarksGradeRelationId = @MarksGradeRelationId;
		SELECT 1 AS 'AffectedRows';

    END TRY
    BEGIN CATCH
        -- Log the exception
        DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();

        EXEC uspExceptionLogInsert 
            @ErrorLine, 
            @ErrorMessage, 
            @ErrorNumber, 
            @ErrorProcedure, 
            @ErrorSeverity, 
            @ErrorState;
     END CATCH
  END
  ELSE
  BEGIN
    SELECT 0 AS 'AffectedRows';
  END
END