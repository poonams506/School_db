-- =============================================
-- Author:    Shambala Apugade
-- Create date: 31/05/2024
-- Description:  This stored procedure is used to get Student kit Payment Analytics for Student
-- =============================================
CREATE PROC [dbo].[uspStudentKitPaymentAnalyticsStudent](@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT s.StudentId, g.GradeId, d.DivisionId, s.FirstName +' ' + s.MiddleName + ' ' + s.LastName AS Studentname,

TotalFee=  dbo.udfStudentKitStudentTotalFee(M.GradeId, M.DivisionId, M.AcademicYearId, M.StudentId),
DiscountedFee = dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId),
CollectionTillDate = dbo.udfStudentKitStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)+dbo.udfStudentKitStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId),
EffectiveFee = dbo.udfStudentKitStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId)- dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId),
ReceivableFee = (dbo.udfStudentKitStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) - dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)) - (dbo.udfStudentKitStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)+ dbo.udfStudentKitStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)),
CollectionInPercentage = CASE WHEN dbo.udfStudentKitStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) - dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) > 0  THEN (dbo.udfStudentKitStudentPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) + dbo.udfStudentKitStudentOtherPaidAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId))/(dbo.udfStudentKitStudentTotalFee(m.GradeId,m.DivisionId,m.AcademicYearId,s.StudentId) - dbo.udfStudentKitStudentDiscountedFee(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId)) * 100 ELSE 0.0 END
	 
FROM StudentGradeDivisionMapping M
INNER JOIN Student S
ON M.StudentId = S.StudentId
Inner join grade g
ON m.GradeId =g.gradeId 
inner Join division d
ON m.DivisionId = d.DivisionId
WHERE m.AcademicYearId = @AcademicYearId and m.GradeId = @GradeId And m.divisionid= @DivisionId AND s.IsDeleted<>1 AND M.IsDeleted <> 1


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