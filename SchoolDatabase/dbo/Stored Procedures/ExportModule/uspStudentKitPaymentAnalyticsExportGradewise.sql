-- =============================================
-- Author:    Shambala Apugade
-- Create date: 31/05/2024
-- Description:  This stored procedure is used to get Export Student Kit export Payment Analytics for Grade
-- =============================================
CREATE PROC [dbo].[uspStudentKitPaymentAnalyticsExportGradewise] (@AcademicYearId SMALLINT,@GradeId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT 
    
	g.GradeName,d.DivisionName,m.RollNumber, s.FirstName + ' '  + s.MiddleName + ' ' + s.LastName AS 'StudentName',
	
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

FROM StudentGradeDivisionMapping M
     INNER JOIN Student S
     ON M.StudentId = S.StudentId
	 INNER JOIN grade g
	 ON m.GradeId =g.gradeId 
	 INNER JOIN division d
	 ON m.DivisionId = d.DivisionId	
	 
WHERE m.AcademicYearId = @AcademicYearId AND g.GradeId= @GradeId  AND s.IsDeleted <> 1 and m.IsDeleted <> 1
GROUP BY g.GradeId,d.DivisionId,d.DivisionName,s.FirstName,s.MiddleName,s.LastName,s.EmergencyContactNumber,g.GradeName,d.DivisionName,m.RollNumber, s.StudentId,M.IsRTEStudent,s.IsNewStudent
ORDER BY d.DivisionName

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