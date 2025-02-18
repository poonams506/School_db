-- =============================================
-- Author: Saurabh Walunj 
-- Create date: 25/07/2024
-- Description: This stored procedure is used for Exam Object Upsert 
-- =============================================
CREATE PROCEDURE [dbo].[uspExamObjectUpsert](
    @AcademicYearId SMALLINT,
    @ExamMasterId SMALLINT,
    @SubjectMasterId INT,
    @Objectdetails [dbo].[CBSE_ExamObjectDetailType] READONLY, -- Table-valued parameter
    @UserId INT
)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- Adjust as needed
    SET NOCOUNT ON;

    DECLARE @CurrentDateTime DATETIME = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION;

        MERGE dbo.CBSE_ExamObject AS target
        USING @Objectdetails AS source  
        ON target.ExamMasterId = @ExamMasterId
        AND target.SubjectMasterId = @SubjectMasterId
        AND target.AcademicYearId = @AcademicYearId
        AND target.ExamObjectId = source.ExamObjectId -- Ensure we match by ExamObjectId

        -- When matching rows are found, update the existing data
        WHEN MATCHED THEN
            UPDATE SET
                target.ObjectName = source.ObjectName,
                target.OutOfMarks = source.OutOfMarks,
                target.ModifiedBy = @UserId,
                target.ModifiedDate = @CurrentDateTime
        
        -- When no matching rows are found, insert new records
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                AcademicYearId, 
                ExamMasterId, 
                SubjectMasterId, 
                ObjectName, 
                OutOfMarks, 
                CreatedBy, 
                CreatedDate
            )
            VALUES (
                @AcademicYearId, 
                @ExamMasterId, 
                @SubjectMasterId, 
                source.ObjectName, 
                source.OutOfMarks, 
                @UserId, 
                @CurrentDateTime
            )

        -- When there are records in the target table that don't match any in the source (input table), delete them
        WHEN NOT MATCHED BY SOURCE
        AND target.AcademicYearId = @AcademicYearId
        AND target.ExamMasterId = @ExamMasterId
        AND target.SubjectMasterId = @SubjectMasterId THEN
            DELETE;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

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
END;