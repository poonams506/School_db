--===============================================
-- Author:- Sanket Ghule
-- Create date:- 28/08/2024
-- Description:- This stored procedure is used to get BulkPaymentReminder by Select.
-- =============================================
CREATE PROCEDURE [dbo].[uspBulkPaymentReminderSelect]  
 @AcademicYearId INT
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY 

 SELECT DISTINCT
    s.StudentId,
    s.FirstName,
    s.MiddleName,
    s.LastName,
	fpp.IsPublished
	
FROM 
    dbo.Student as s
	inner join dbo.StudentGradeDivisionMapping m
	on s.StudentId = m.StudentId AND m.AcademicYearId = @AcademicYearId AND m.IsDeleted <> 1
	Left Join dbo.FeePayment fp 
	ON fp.StudentId = s.StudentId AND fp.IsDeleted <> @AcademicYearId AND fp.AcademicYearId = @AcademicYearId
	inner join dbo.FeeParticular fpp
	on m.GradeId=fpp.GradeId AND fpp.AcademicYearId = @AcademicYearId AND m.DivisionId=fpp.DivisionId 
	AND  fpp.IsDeleted<>1 AND fpp.IsPublished=1

WHERE 
    s.IsDeleted <> 1
	AND fp.FeePaymentId IS NULL

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
    END CATCH
END