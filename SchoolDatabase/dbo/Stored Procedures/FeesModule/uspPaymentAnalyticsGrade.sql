-- =============================================
-- Author:    Shambala Apugade
-- Create date: 07/02/2023
-- Description:  This stored procedure is used to get Payment Analytics for Grade
-- =============================================
CREATE PROC [dbo].[uspPaymentAnalyticsGrade] (@AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT  g.GradeId, g.GradeName,
TotalFee=  SUM(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId)),
DiscountedFee = SUM(dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
CollectionTillDate = SUM(dbo.udfStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))+SUM(dbo.udfStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
EffectiveFee = SUM(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId))- SUM(dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
ReceivableFee = (SUM(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) )- SUM(dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) - ( SUM( dbo.udfStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))+SUM(dbo.udfStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))),
CollectionInPercentage = CASE WHEN (SUM(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId)) - SUM(dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) > 0  THEN (SUM(dbo.udfStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)) + SUM(dbo.udfStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)))/(SUM(dbo.udfStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId)) - SUM(dbo.udfStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))) * 100 ELSE 0.0 END
     FROM StudentGradeDivisionMapping M
     INNER JOIN Student S
     ON M.StudentId = S.StudentId
	 INNER JOIN Grade g
	 ON m.GradeId =g.gradeId 
	 INNER JOIN Division d
	 ON m.DivisionId = d.DivisionId
     WHERE m.AcademicYearId = @AcademicYearId AND s.IsDeleted <>1 AND M.IsDeleted <> 1
	 GROUP BY g.GradeId, g.GradeName


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