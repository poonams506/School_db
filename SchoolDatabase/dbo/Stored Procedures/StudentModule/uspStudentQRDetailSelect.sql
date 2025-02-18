
-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 06/0/72024
-- Description:  This stored procedure is to get QR Code detail by Student Id
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentQRDetailSelect]
(
  @StudentId BIGINT,
  @AcademicYearId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

   BEGIN TRY 
		
	SELECT s.StudentId,s.FirstName AS StudentFullName,
	CONCAT(g.GradeName,' - ',d.DivisionId) AS Class,sgdm.RollNumber
	FROM dbo.Student s JOIN
	dbo.StudentGradeDivisionMapping sgdm ON s.StudentId=sgdm.StudentId JOIN
	dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
	dbo.Division d ON sgdm.DivisionId=d.DivisionId
	WHERE s.StudentId=@StudentId AND sgdm.AcademicYearId=@AcademicYearId;
 
  END TRY

BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
@ErrorState END CATCH END