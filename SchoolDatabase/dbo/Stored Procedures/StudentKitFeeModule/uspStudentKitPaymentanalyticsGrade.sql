-- =============================================
-- Author:    Shambala Apugade
-- Create date: 31/05/2024
-- Description:  This stored procedure is used to get Student kit Payment Analytics for Division
-- =============================================
CREATE PROC [dbo].[uspStudentKitPaymentAnalyticsGrade] (@AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY

SELECT g.GradeId, g.GradeName,
TotalFee=  SUM(dbo.udfStudentKitStudentTotalFee(M.GradeId, M.DivisionId, M.AcademicYearId, M.StudentId)),
DiscountedFee = SUM(dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
CollectionTillDate = SUM(dbo.udfStudentKitStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))+SUM(dbo.udfStudentKitStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
EffectiveFee = SUM(dbo.udfStudentKitStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId))- SUM(dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
ReceivableFee = (SUM(dbo.udfStudentKitStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) )- SUM(dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) - ( SUM( dbo.udfStudentKitStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))+SUM(dbo.udfStudentKitStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))),
CollectionInPercentage = CASE WHEN (SUM(dbo.udfStudentKitStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId)) - SUM(dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) > 0  THEN (SUM(dbo.udfStudentKitStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)) + SUM(dbo.udfStudentKitStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)))/(SUM(dbo.udfStudentKitStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId)) - SUM(dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) * 100 ELSE 0.0 END
	 
FROM StudentGradeDivisionMapping M
     INNER JOIN Student S
     ON M.StudentId = S.StudentId
	 INNER JOIN grade g
	 ON m.GradeId =g.gradeId 
	 INNER JOIN division d
	 ON m.DivisionId = d.DivisionId	
WHERE m.AcademicYearId = @AcademicYearId  AND s.IsDeleted<>1 AND M.IsDeleted <> 1
GROUP BY g.GradeName,g.GradeId

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
