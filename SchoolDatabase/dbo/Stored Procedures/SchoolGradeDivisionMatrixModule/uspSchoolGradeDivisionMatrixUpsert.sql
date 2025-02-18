-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 23/08/2023
-- Description:  This stored procedure is used insert or update school grade division matrix info
-- =============================================
CREATE PROCEDURE uspSchoolGradeDivisionMatrixUpsert (
 @GradeId INT,
 @Divisions dbo.DivisionType READONLY,
 @UserId INT,
 @AcademicYearId INT
) AS 
BEGIN 
    SET 
      TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    SET 
      NOCOUNT ON 
    
      DECLARE @CurrentDateTime DATETIME = GETDATE();
    BEGIN TRY 
    
    --DELETE 
    -- FROM 
    --     SchoolGradeDivisionMatrix 
    -- WHERE 
    -- GradeId=@GradeId;

     INSERT INTO SchoolGradeDivisionMatrix (GradeId, DivisionId,AcademicYearId, CreatedBy, CreatedDate)
     SELECT @GradeId, DivisionId ,@AcademicYearId, @UserId, @CurrentDateTime FROM @Divisions;

    
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
