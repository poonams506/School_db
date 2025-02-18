-- =============================================
-- Author:    Shambala Apugade
-- Create date: 04/03/2024
-- Description:  This stored procedure is used to get Payment Analytics for Grade
-- =============================================
CREATE PROC [dbo].[uspPaymentAnalyticsExportSchoolwise] (@AcademicYearId SMALLINT) AS Begin 
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
			
		TotalFee=  SUM(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) ),
		DiscountedFee = SUM(dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)) ,
		EffectiveFee = SUM(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) )- SUM(dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
		CollectionTillDate =SUM( dbo.udfStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))+SUM(dbo.udfStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
		ReceivableFee = (SUM(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) )- SUM(dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) - ( SUM( dbo.udfStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))+SUM(dbo.udfStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))),
		CollectionInPercentage = CASE WHEN (SUM(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId)) - SUM(dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) > 0  THEN (SUM(dbo.udfStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)) + SUM(dbo.udfStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)))/(SUM(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId)) - SUM(dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) * 100 ELSE 0.0 END,
		
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