-- =============================================
-- Author:   Tejas Rahane
-- Create date: 20/11/2024
-- Description:  This stored procedure is used to check Subject index number exists
-- =============================================
CREATE PROCEDURE [dbo].[uspCheckSubjectIndexNumberExists]
    @AcademicYearId SMALLINT,
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

        
        DECLARE @DuplicateCheck TABLE (
            SubjectMasterId BIGINT,
            IndexNumber INT,
            SubjectName NVARCHAR(255),
            IsDuplicate BIT
        );

        
        INSERT INTO @DuplicateCheck (SubjectMasterId, IndexNumber, SubjectName, IsDuplicate)
        SELECT 
            SD.SubjectMasterId,
            SD.IndexNumber,
            SD.SubjectName,

            CASE 
                WHEN EXISTS (
                    SELECT 1
                    FROM dbo.SubjectMapping SM
                    WHERE SM.AcademicYearId = @AcademicYearId
                      AND SM.GradeId = @GradeId
                      AND SM.DivisionId = @DivisionId
                      AND SM.IndexNumber = SD.IndexNumber
                      AND SM.SubjectMasterId != SD.SubjectMasterId
                      AND SM.IsDeleted = 0
                ) THEN 1
                ELSE 0
            END AS IsDuplicate
        FROM @SubjectDetails SD;

        
        IF EXISTS (SELECT 1 FROM @DuplicateCheck WHERE IsDuplicate = 1)
        BEGIN
            
            SELECT SubjectMasterId, IndexNumber, SubjectName, IsDuplicate 
            FROM @DuplicateCheck
            WHERE IsDuplicate = 1;

            
            ROLLBACK TRANSACTION;
            RETURN; 
        END

        
        MERGE dbo.SubjectMapping AS Target
        USING @SubjectDetails AS Source
        ON Target.[SubjectMasterId] = Source.[SubjectMasterId]
           AND Target.[AcademicYearId] = @AcademicYearId
           AND Target.[GradeId] = @GradeId
           AND Target.[DivisionId] = @DivisionId
        WHEN MATCHED THEN
            UPDATE 
            SET 
                Target.[IndexNumber] = Source.[IndexNumber]
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ([SubjectMasterId], [AcademicYearId], [GradeId], [DivisionId], [IndexNumber])
            VALUES (Source.[SubjectMasterId], @AcademicYearId, @GradeId, @DivisionId, Source.[IndexNumber]);

        
        SELECT SubjectMasterId, IndexNumber, SubjectName, IsDuplicate 
        FROM @DuplicateCheck;

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
    END CATCH;
END;
GO