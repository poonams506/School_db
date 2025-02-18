--===============================================
-- Author:     Meena Kotkar
-- Create date: 28/08/2024
-- Description:  Select Stored Procedure for Exam List by Selected classes
-- ================================================
CREATE PROCEDURE [dbo].[uspExamMasterDropdownForReport]
(
    @AcademicYearId SMALLINT,
    @ClassId dbo.SingleIdType READONLY
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @classIds TABLE(Id INT);  
        INSERT INTO @classIds SELECT Id FROM @ClassId;

        DECLARE @classIdCount INT = (SELECT COUNT(Id) FROM @classIds);

        SELECT DISTINCT
            e.ExamMasterId,
            e.ExamName,
			et.ExamTypeName,
            e.TermId
        FROM
            CBSE_ExamMaster AS e
            INNER JOIN CBSE_Term ct ON e.TermId = ct.TermId
            INNER JOIN dbo.CBSE_ClassExamMapping sgm ON e.ExamMasterId = sgm.ExamMasterId
            INNER JOIN dbo.[SchoolGradeDivisionMatrix] sgdm ON sgm.GradeId = sgdm.GradeId 
                AND sgm.DivisionId = sgdm.DivisionId
			INNER JOIN CBSE_ExamType et ON e.ExamTypeId=et.ExamTypeId
        WHERE
            e.AcademicYearId = @AcademicYearId
            AND sgm.AcademicYearId=@AcademicYearId
            AND sgdm.AcademicYearId=@AcademicYearId
            AND e.IsDeleted <> 1
            AND sgm.IsDeleted <> 1
            AND ct.IsDeleted <> 1
            AND (
                @classIdCount = 0 
                OR NOT EXISTS (
                    SELECT 1 
                    FROM @classIds cid 
                    WHERE NOT EXISTS (
                        SELECT 1 
                        FROM dbo.SchoolGradeDivisionMatrix sgdmInner
                        INNER JOIN dbo.CBSE_ClassExamMapping sgmInner
                            ON sgdmInner.GradeId= sgmInner.GradeId AND sgdmInner.DivisionId= sgmInner.DivisionId 
                        WHERE sgdmInner.SchoolGradeDivisionMatrixId = cid.Id 
                            AND e.ExamMasterId = sgmInner.ExamMasterId  
                            AND sgmInner.AcademicYearId=@AcademicYearId
                    )
                )
            )
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
    END CATCH
END
