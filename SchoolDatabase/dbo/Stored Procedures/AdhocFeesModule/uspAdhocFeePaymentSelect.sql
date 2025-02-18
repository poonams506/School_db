-- =============================================
-- Author:    Deepak Walunj
-- Create date: 31/08/2023
-- Description:  This stored procedure is used to get Fee Payment info detail by student Id
-- =============================================
CREATE PROCEDURE [dbo].[uspAdhocFeePaymentSelect]
	@StudentId BIGINT,
	@AcademicYearId SMALLINT,
	@GradeId SMALLINT,
	@DivisionId SMALLINT
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
        
               -- 1st result for student info
        SELECT 
		s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName AS 'FullName',
		s.GeneralRegistrationNo,
		s.IsNewStudent,
		m.IsRTEStudent,
		s.AppAccessMobileNo,
		m.AcademicYearId,
		m.RollNumber,
		g.GradeName,
		d.DivisionName
		FROM Student s
		INNER JOIN StudentGradeDivisionMapping m
		ON s.StudentId = m.StudentId
		INNER JOIN Grade g
		ON m.GradeId = m.GradeId
		INNER JOIN Division d
		ON m.DivisionId = d.DivisionId
		WHERE ISNULL(s.IsDeleted,0) <> 1
		AND ISNULL(s.IsArchive,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(g.IsDeleted,0) <> 1
		AND ISNULL(d.IsDeleted,0) <> 1
		AND m.AcademicYearId = @AcademicYearId
		AND m.StudentId = @StudentId
		AND m.GradeId = @GradeId
		AND m.DivisionId = @DivisionId
		AND g.GradeId = @GradeId
		AND d.DivisionId = @DivisionId

		
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