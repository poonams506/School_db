-- =============================================
-- Author:    Shambala Apugade
-- Create date: 04/03/2024
-- Description:  This stored procedure is used to get Payment Analytics for Division
-- =============================================
CREATE PROC [dbo].[uspPaymentAnalyticsExportDivisionwise] (@GradeId SMALLINT, @AcademicYearId SMALLINT,@DivisionId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT
		
		g.GradeName,d.DivisionName, m.RollNumber, s.FirstName + ' ' +s.MiddleName + ' ' + s.LastName AS Studentname,
		
		CASE WHEN M.IsRTEStudent = 1 THEN 'YES'
		ELSE 'NO' END AS IsRTEStudent,
		CASE WHEN s.IsNewStudent =1 THEN 'YES'
		ELSE 'NO' END AS IsNewStudent ,

		TotalFee =  dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId),
		DiscountedFee = dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId),
		EffectiveFee = dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) - dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId),
		CollectionTillDate = dbo.udfStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)+ dbo.udfStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId),
		ReceivableFee = (dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId)- dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))-(dbo.udfStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)+dbo.udfStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
		CollectionInPercentage = CASE WHEN dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) - dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) > 0  THEN (dbo.udfStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) + dbo.udfStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))/(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) - dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)) * 100 ELSE 0.0 END,
		s.EmergencyContactNumber AS ContactNo
	 
FROM 
		StudentGradeDivisionMapping M
		INNER JOIN Student S
		ON M.StudentId = S.StudentId
		INNER JOIN Grade g
		ON m.GradeId =g.gradeId 
		INNER JOIN Division d
		ON m.DivisionId = d.DivisionId
WHERE  
		m.AcademicYearId = @AcademicYearId AND m.GradeId = @GradeId AND m.Divisionid= @DivisionId AND s.IsDeleted <>1 and m.IsDeleted <> 1
		


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
@ErrorState END CATCH
END