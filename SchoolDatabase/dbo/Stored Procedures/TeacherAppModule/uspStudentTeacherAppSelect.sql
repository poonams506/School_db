-- =============================================
-- Author: Saurabh Walunj
-- Create date: 22/03/2024
-- Description: This stored procedure is used to get student info for teacher app
-- =============================================
CREATE PROCEDURE uspStudentTeacherAppSelect (@AcademicYearId INT, @GradeId INT, @DivisionId INT) AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
       
    SELECT
		CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) AS StudentName,
		m.RollNumber,
		s.Gender,
		s.EmergencyContactNumber,
        s.ProfileImageURL


  FROM Student s 
  INNER JOIN StudentGradeDivisionMapping m ON s.StudentId=m.StudentId
  INNER JOIN Grade g ON m.GradeId = g.GradeId
  INNER JOIN Division d ON m.DivisionId = d.DivisionId


  WHERE
    ISNULL(s.IsDeleted,0)<>1 AND ISNULL(s.IsArchive,0)<>1 AND ISNULL(m.IsDeleted,0)<>1 AND
    m.AcademicYearId = @AcademicYearId
	AND m.GradeId = @GradeId
	AND m.DivisionId = @DivisionId
    ORDER BY m.RollNumber ASC


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
END;

