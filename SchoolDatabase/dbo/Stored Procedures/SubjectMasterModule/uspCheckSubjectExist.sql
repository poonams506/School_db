-- =============================================
-- Author:   Chaitanya Kasar
-- Create date: 29/03/2024
-- Description:  This stored procedure is used to check Subject  exist or not 
-- =============================================

CREATE PROCEDURE [dbo].[uspCheckSubjectExist]
(
    @SubjectMasterId INT= NULL
)
    AS 
    BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
    DECLARE @CurrentDateTime DATETIME = GETDATE();
    DECLARE @SubjectMappingCount INT;
    DECLARE @TeacherSubjectMappingCount INT;
    Declare @ObjectCount INT;
    SELECT @SubjectMappingCount = COUNT(SubjectMasterId) 
    FROM SubjectMapping
    WHERE SubjectMasterId = @SubjectMasterId

    SELECT @TeacherSubjectMappingCount = COUNT(SubjectMasterId) 
    FROM TeacherSubjectMapping
    WHERE SubjectMasterId = @SubjectMasterId 

    SELECT @ObjectCount = COUNT(SubjectMasterId) 
    FROM CBSE_ExamObject
    WHERE SubjectMasterId = @SubjectMasterId
    	  AND IsDeleted <> 1


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
    SELECT @SubjectMappingCount as 'SubjectMappingCount',
           @TeacherSubjectMappingCount as 'TeacherSubjectMappingCount',
           @ObjectCount as 'ObjectCount';

   END;

