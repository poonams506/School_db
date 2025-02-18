-- =============================================
-- Author:   Chaitanya Kasar
-- Create date: 30/03/2024
-- Description:  This stored procedure is used to check Subject exist or not 
-- =============================================
CREATE PROCEDURE [dbo].[uspCheckExistSubject]
(
   @GradeId INT,
   @DivisionId INT,
   @AcademicYearId INT,
   @SubjectId INT
)
    AS 
    BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
     DECLARE @Exist TABLE (SubjectName NVARCHAR(200), ExistsInHomeWork INT, ExistsInClassTimeTable INT );
 
    INSERT INTO @Exist (SubjectName, ExistsInHomeWork, ExistsInClassTimeTable )
     SELECT m.SubjectName, 
        CASE 
                   WHEN EXISTS (
                       SELECT 1 
                       FROM HomeWork h
                       WHERE h.SubjectId = @SubjectId
                       AND h.IsDeleted <> 1
					   AND h.AcademicYearId = @AcademicYearId
					   AND m.IsDeleted <> 1
					   AND h.GradeId=@GradeId
					   AND h.DivisionId=@DivisionId
                   ) THEN 1
                   ELSE 0
               END AS 'ExistsInHomeWork',
                  CASE 
                WHEN EXISTS (
                    SELECT 1 
                     FROM ClassTimeTableColumnDetail c
					INNER JOIN [dbo].[ClassTimeTable] 
					ct ON c.ClassTimeTableId = ct.ClassTimeTableId
                    WHERE c.SubjectId = @SubjectId
					 AND ct.AcademicYearId = @AcademicYearId
					 AND c.IsDeleted <> 1
					 AND ct.IsDeleted <> 1
					 AND ct.GradeId=@GradeId
					 AND ct.DivisionId=@DivisionId
                ) THEN 1
                ELSE 0
            END AS 'ExistsInClassTimeTable'
        FROM 
		SubjectMaster m WHERE m.SubjectMasterId = @SubjectId;
		
        SELECT SubjectName, ExistsInHomeWork, ExistsInClassTimeTable FROM @Exist;

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
END;
