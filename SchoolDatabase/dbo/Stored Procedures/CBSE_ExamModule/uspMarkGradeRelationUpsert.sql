-- =============================================
-- Author: Tejas Rahane
-- Create date: 25/07/2024
-- Description: This stored procedure is used to upsert MarksGradeRelation
-- =============================================
 CREATE PROCEDURE [dbo].[uspCBSE_MarksGradeRelationUpsert](
  @MarksGradeRelationId BIGINT,
  @AcademicYearId SMALLINT,
  @MaxMark INT,
  @MinMark INT,
  @Grade NVARCHAR(5),
  @UserId INT
) 
AS 
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  SET NOCOUNT ON;
  
  DECLARE @CurrentDateTime DATETIME = GETDATE();

  BEGIN TRY
    -- Check for overlapping ranges    
    IF EXISTS (            
      SELECT 1
      FROM dbo.CBSE_MarksGradeRelation
      WHERE 
        MarksGradeRelationId <> @MarksGradeRelationId AND
        IsDeleted = 0 AND
        AcademicYearId = @AcademicYearId AND
        (
          (@MinMark BETWEEN MinMark AND MaxMark - 1) OR
          (@MaxMark BETWEEN MinMark + 1 AND MaxMark) OR
          (MinMark BETWEEN @MinMark + 1 AND @MaxMark - 1) OR
          (MaxMark BETWEEN @MinMark + 1 AND @MaxMark - 1)
        )
    )
    BEGIN
      -- If overlapping range exists, return -2 (custom error code)
      SELECT -2 AS ErrorCode;
      RETURN;
    END

    -- Proceed with update or insert
    IF @MarksGradeRelationId > 0 
    BEGIN
      -- Update statement
      UPDATE dbo.CBSE_MarksGradeRelation
      SET 
        AcademicYearId = @AcademicYearId,
        MaxMark = @MaxMark, 
        MinMark = @MinMark, 
        Grade = @Grade, 
        ModifiedBy = @UserId, 
        ModifiedDate = @CurrentDateTime
      WHERE 
        MarksGradeRelationId = @MarksGradeRelationId;
    END 
    ELSE 
    BEGIN
      -- Insert statement
      INSERT INTO dbo.CBSE_MarksGradeRelation(
        AcademicYearId, 
        MaxMark, 
        MinMark, 
        Grade, 
        CreatedBy, 
        CreatedDate
      ) 
      VALUES (
        @AcademicYearId, 
        @MaxMark, 
        @MinMark, 
        @Grade, 
        @UserId, 
        @CurrentDateTime
      );

      SET @MarksGradeRelationId = SCOPE_IDENTITY();
    END
  END TRY 
  BEGIN CATCH 
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
  END CATCH;
END;