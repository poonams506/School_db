-- ==============================================================
-- Author:    Poonam Bhalke
-- Create date: 13/02/2024
-- Description:  This stored procedure is used to get Promote info
-- ==============================================================

CREATE PROC uspPromoteGridSelect (
@AcademicYearId INT,
@GradeId INT,
@DivisionId INT
) AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY
     
       SELECT 
               g.GradeName,
               d.DivisionName,
               s.StudentId,
               s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName AS 'FullName',
               sdgm.IsPassed,
               sdgm.PromotedAcademicYearId,
               sdgm.PromotedGradeId,
               sdgm.PromotedDivisionId,
               sdgm.RollNumber
               
            FROM 
             StudentGradeDivisionMapping sdgm
             INNER JOIN Grade g ON sdgm.GradeId = g.GradeId
             INNER JOIN Division d ON sdgm.DivisionId = d.DivisionId
             INNER JOIN Student s ON sdgm.StudentId = s.StudentId

            WHERE
                ISNULL(sdgm.IsDeleted, 0) <> 1 AND s.IsDeleted <> 1 AND s.IsArchive <> 1
                AND sdgm.AcademicYearId = @AcademicYearId
                AND ((g.GradeId = ISNULL(@GradeId, g.GradeId) OR g.GradeId = @GradeId)
                AND (d.DivisionId = ISNULL(@DivisionId, d.DivisionId) OR d.DivisionId = @DivisionId))
            ORDER BY sdgm.RollNumber ASC
                
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

