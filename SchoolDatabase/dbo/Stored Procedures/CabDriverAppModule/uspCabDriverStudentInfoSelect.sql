-- =============================================
-- Author:    Shambala Apugade
-- Create date: 04/07/2024
-- Description:  This stored procedure is used to get Route for CabDriver
-- =============================================
CREATE PROCEDURE [dbo].[uspCabDriverStudentInfoSelect](
@AcademicYearId SMALLINT,
@StudentId BIGINT
) AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY 

SELECT  sc.SchoolId,sc.SchoolCode,s.StudentId,s.FirstName+' '+s.LastName AS StudentName, g.GradeName+' '+d.DivisionName AS ClassName, 
s.Gender,
s.EmergencyContactNumber 

FROM dbo.Student s
INNER JOIN dbo.StudentGradeDivisionMapping m
ON s.StudentId = m.StudentId
INNER JOIN dbo.Grade g
ON g.GradeId = m.GradeId
INNER JOIN dbo.Division d
ON d.DivisionId = m.DivisionId
INNER JOIN dbo.AcademicYear a
ON a.AcademicYearId = m.AcademicYearId
INNER JOIN dbo.School sc
ON sc.SchoolId = s.SchoolId

WHERE m.AcademicYearId = @AcademicYearId 
		AND s.StudentId = @StudentId
		AND s.IsDeleted <> 1 
		AND m.IsDeleted <> 1

END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
@ErrorState END CATCH End
GO