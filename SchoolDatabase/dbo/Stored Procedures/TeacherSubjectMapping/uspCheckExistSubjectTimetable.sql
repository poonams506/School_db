-- =============================================
-- Author:   Chaitanya Kasar
-- Create date: 03/04/2024
-- Description:  This stored procedure is used to check Subject exist or not 
-- =============================================
CREATE PROCEDURE [dbo].[uspCheckExistSubjectTimetable]
(
   @TeacherId INT,
   @AcademicYearId INT,
   @SubjectId INT
)
    AS 
    BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
     DECLARE @Exist TABLE (SubjectName NVARCHAR(200), ExistsInClassTimeTable INT );
 
    INSERT INTO @Exist (SubjectName, ExistsInClassTimeTable )
     SELECT m.SubjectName, 
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
					 AND c.TeacherId=@TeacherId
					 AND ct.isActive=1 AND c.IsDeleted <> 1
                ) THEN 1
                ELSE 0
            END AS 'ExistsInClassTimeTable'
        FROM 
		SubjectMaster m WHERE m.SubjectMasterId = @SubjectId;
		
        SELECT SubjectName, ExistsInClassTimeTable FROM @Exist;

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
