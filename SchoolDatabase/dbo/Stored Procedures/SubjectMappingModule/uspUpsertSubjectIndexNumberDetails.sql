-- =============================================
-- Author:         Tejas Rahane
-- Create date:    26/10/2024
-- Description:    This stored procedure is used for upserting SubjectIndexNumber details.
-- =============================================
CREATE PROCEDURE [dbo].[uspUpsertSubjectIndexNumberDetails]
    @AcademicYearId SMALLINT,
    @SubjectMappingId BIGINT,  
    @UserId INT,
    @GradeId SMALLINT,
    @DivisionId SMALLINT,
    @SubjectDetails [dbo].[SubjectMasterIndexType] READONLY
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
              
    DECLARE @CurrentDateTime DATETIME = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION;

        MERGE dbo.SubjectMapping AS Target
        USING @SubjectDetails AS Source
        ON Target.[SubjectMasterId] = Source.[SubjectMasterId]
           AND Target.[AcademicYearId] = @AcademicYearId
           AND Target.[GradeId] = @GradeId
           AND Target.[DivisionId] = @DivisionId
          
        WHEN MATCHED THEN
            UPDATE 
            SET 
                Target.[IndexNumber] = Source.[IndexNumber],
                Target.[ModifiedBy] = @UserId,
                Target.[ModifiedDate] = @CurrentDateTime
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ([SubjectMasterId], [AcademicYearId], [GradeId], [DivisionId], [IndexNumber], [ModifiedBy], [ModifiedDate])
            VALUES (Source.[SubjectMasterId], @AcademicYearId, @GradeId, @DivisionId, Source.[IndexNumber], @UserId, @CurrentDateTime);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
        EXEC uspExceptionLogInsert 
            @ErrorLine = @ErrorLine, 
            @ErrorMessage = @ErrorMessage, 
            @ErrorNumber = @ErrorNumber, 
            @ErrorProcedure = @ErrorProcedure, 
            @ErrorSeverity = @ErrorSeverity, 
            @ErrorState = @ErrorState;
        THROW;
    END CATCH;
END;