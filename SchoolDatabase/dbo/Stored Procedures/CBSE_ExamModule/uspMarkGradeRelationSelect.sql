
-- =============================================
-- Author:    Tejas Rahane
-- Create date: 24/07/2024
-- Description:  This stored procedure is used to 
-- =============================================
CREATE PROCEDURE uspCBSE_MarksGradeRelationSelect
( 
    @MarksGradeRelationId BIGINT
)
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
--DECLARE @AcademicYearId INT;

select 
mr.MarksGradeRelationId,
mr.AcademicYearId,
mr.MaxMark,
mr.MinMark,
mr.Grade

from CBSE_MarksGradeRelation mr

where 
mr.IsDeleted <> 1
AND mr.MarksGradeRelationId =@MarksGradeRelationId

 END 
 TRY 
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

