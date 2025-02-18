-- =============================================
-- Author:   Chaitanya Kasar
-- Create date: 30/03/2024
-- Description:  This stored procedure is used to check Teacher exist or not 
-- =============================================
CREATE PROCEDURE [dbo].[uspCheckTeacherExist]
(
    @TeacherId INT= NULL
)
    AS 
    BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
    DECLARE @CurrentDateTime DATETIME = GETDATE();
    DECLARE @TeacherGradeDivisionMappingCount INT;
    DECLARE @TeacherSubjectMappingCount INT;

    SELECT @TeacherGradeDivisionMappingCount = COUNT(TeacherId) 
    FROM TeacherGradeDivisionMapping
    WHERE TeacherId = @TeacherId AND IsDeleted <> 1

    SELECT @TeacherSubjectMappingCount = COUNT(TeacherId) 
    FROM TeacherSubjectMapping
    WHERE TeacherId = @TeacherId  AND IsDeleted <> 1
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
    END CATCH; -- End of CATCH block 
    SELECT @TeacherGradeDivisionMappingCount as 'TeacherGradeDivisionMappingCount',
           @TeacherSubjectMappingCount as 'TeacherSubjectMappingCount';
   END;



