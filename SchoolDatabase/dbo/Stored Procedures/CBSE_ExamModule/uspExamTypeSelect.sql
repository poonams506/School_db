--===============================================
-- Author:    Prerana Aher
-- Create date: 26/7/2024
-- Description:  Select Stored Procedure for Exam Type info detail by Select
-- =============================================
 CREATE PROCEDURE [dbo].[uspExamTypeSelect]
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY 

SELECT
e.ExamTypeId,
e.ExamTypeName

FROM
	  CBSE_ExamType as e

        WHERE
	         e.IsDeleted <> 1
           
	
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
            @ErrorState;
    END CATCH
END