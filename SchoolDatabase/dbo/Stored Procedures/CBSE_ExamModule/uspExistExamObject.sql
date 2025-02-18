-- =============================================
-- Author: Saurabh Walunj 
-- Create date: 19/09/2024
-- Description: This stored procedure is used to info about exist
-- =============================================
CREATE PROCEDURE [dbo].[uspExistExamObject]
(
  @ExamMasterId BIGINT, 
  @SubjectMasterId BIGINT, 
  @ObjectDetails [dbo].[CBSE_ExamObjectDetailType] READONLY,  -- Table-valued parameter
  @AcademicYearId INT
) 
AS 
BEGIN 
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  SET NOCOUNT ON;

  BEGIN TRY 
    DECLARE @ExamObjectId BIGINT;
    DECLARE @ObjectName NVARCHAR(200);
    DECLARE @DuplicateCount INT = 0;  -- To track the number of duplicates

    -- Temporary table to store duplicate details
    DECLARE @DuplicateObjects TABLE (
      ExamObjectId BIGINT,
      ObjectName NVARCHAR(200)
    );

    -- Cursor to loop through the object details (ExamObjectId and ObjectName)
    DECLARE object_cursor CURSOR FOR 
    SELECT ExamObjectId, ObjectName FROM @ObjectDetails;

    OPEN object_cursor;
    FETCH NEXT FROM object_cursor INTO @ExamObjectId, @ObjectName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
      -- Check if the new ObjectName already exists, excluding the current object being updated
      IF EXISTS (
        SELECT TOP (1) ExamObjectId  
        FROM dbo.CBSE_ExamObject
        WHERE ExamObjectId <> @ExamObjectId  -- Exclude the current object being updated
        AND SubjectMasterId = @SubjectMasterId
        AND ExamMasterId = @ExamMasterId 
        AND ObjectName = @ObjectName
        AND AcademicYearId = @AcademicYearId
        AND IsDeleted = 0
      )
      BEGIN
        -- Insert the duplicate into the temp table
        INSERT INTO @DuplicateObjects (ExamObjectId, ObjectName)
        SELECT ExamObjectId, ObjectName
        FROM dbo.CBSE_ExamObject
        WHERE ExamObjectId <> @ExamObjectId
        AND SubjectMasterId = @SubjectMasterId
        AND ExamMasterId = @ExamMasterId
        AND ObjectName = @ObjectName
        AND AcademicYearId = @AcademicYearId
        AND IsDeleted = 0;

        -- Increment duplicate count
        SET @DuplicateCount = @DuplicateCount + 1;
      END

      FETCH NEXT FROM object_cursor INTO @ExamObjectId, @ObjectName;
    END;

    -- Close and deallocate the cursor
    CLOSE object_cursor;
    DEALLOCATE object_cursor;

    -- Return the duplicate count and details (if duplicates exist)
    IF @DuplicateCount > 0
    BEGIN
      --SELECT @DuplicateCount AS 'ObjectExist';  -- Return total number of duplicates
      SELECT Distinct(ExamObjectId) ,ObjectName FROM @DuplicateObjects;  -- Return details of all duplicates
    END
    ELSE
    BEGIN
      -- If no duplicates found, return 0
      SELECT 0 AS 'ObjectExist';
    END;

  END TRY
  BEGIN CATCH 
    -- Error handling logic
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