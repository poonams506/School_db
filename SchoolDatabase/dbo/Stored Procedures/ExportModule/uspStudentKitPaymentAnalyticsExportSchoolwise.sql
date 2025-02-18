-- =============================================
-- Author:    Shambala Apugade
-- Create date: 31/05/2024
-- Description:  This stored procedure is used to get Export Student Kit Payment Analytics for School
-- =============================================
CREATE PROC [dbo].[uspStudentKitPaymentAnalyticsExportSchoolwise] (@AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT 
		sc.SchoolName,
		g.GradeName,d.DivisionName,m.RollNumber, s.FirstName + ' ' + s.MiddleName +' '+ s.LastName AS 'StudentName',
		CASE WHEN M.IsRTEStudent = 1 then 'YES'
		ELSE 'NO' END AS IsRTEStudent,
		CASE WHEN s.IsNewStudent =1 THEN 'YES'
		ELSE 'NO' END AS IsNewStudent ,
		
		TotalFee=  SUM(dbo.udfStudentKitStudentTotalFee(M.GradeId, M.DivisionId, M.AcademicYearId, M.StudentId)),
		DiscountedFee = SUM(dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
		CollectionTillDate = SUM(dbo.udfStudentKitStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))+SUM(dbo.udfStudentKitStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
		EffectiveFee = SUM(dbo.udfStudentKitStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId))- SUM(dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
		ReceivableFee = (SUM(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) )- SUM(dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) - ( SUM( dbo.udfStudentKitStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))+SUM(dbo.udfStudentKitStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))),
		CollectionInPercentage = CASE WHEN (SUM(dbo.udfStudentKitStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId)) - SUM(dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) > 0  THEN (SUM(dbo.udfStudentKitStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)) + SUM(dbo.udfStudentKitStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)))/(SUM(dbo.udfStudentKitStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId)) - SUM(dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) * 100 ELSE 0.0 END,

		s.EmergencyContactNumber AS ContactNo
	
FROM     StudentGradeDivisionMapping M
		 INNER JOIN Student S
		 ON M.StudentId = S.StudentId
		 INNER JOIN school sc
		 ON s.SchoolId =sc.SchoolId
		 INNER JOIN Grade g
		 ON m.GradeId = g.GradeId
		 INNER JOIN Division d
		 ON m.DivisionId = d.DivisionId
		
WHERE m.AcademicYearId = @AcademicYearId  AND s.IsDeleted <> 1 and m.IsDeleted <> 1
GROUP BY s.FirstName+' ' +s.MiddleName +' '+ s.LastName,s.EmergencyContactNumber,m.RollNumber,g.GradeName,d.DivisionName, s.StudentId,M.IsRTEStudent,s.IsNewStudent,sc.SchoolName
ORDER BY g.GradeName, d.DivisionName


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