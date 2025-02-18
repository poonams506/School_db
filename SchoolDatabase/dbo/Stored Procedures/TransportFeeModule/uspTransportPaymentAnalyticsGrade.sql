-- =============================================
-- Author:    Shambala Apugade
-- Create date: 27/05/2024
-- Description:  This stored procedure is used to get Payment Analytics for School
-- =============================================
CREATE PROC [dbo].[uspTransportPaymentAnalyticsGrade] (@AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 


SELECT  
	g.GradeId, g.GradeName,
	TransportTotalFee=  SUM(dbo.udfConsumerTransportTotalFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))),
	TransportDiscountedFee = SUM(dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))),
	TransportCollectionTillDate =SUM(dbo.udfConsumerTransportPaidAmount (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))+SUM(dbo.udfConsumerTransportOtherPaidAmount (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))),
	TransportEffectiveFee = SUM(dbo.udfConsumerTransportTotalFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))- SUM(dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))),
	TransportReceivableFee = (SUM(dbo.udfConsumerTransportTotalFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))- SUM(dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))) - ( SUM(dbo.udfConsumerTransportPaidAmount (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))+SUM(dbo.udfConsumerTransportOtherPaidAmount (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))),
	TransportCollectionInPercentage = CASE WHEN (SUM(dbo.udfConsumerTransportTotalFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))) - SUM(dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))) > 0  THEN (SUM(dbo.udfConsumerTransportPaidAmount(m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))) + SUM(dbo.udfConsumerTransportOtherPaidAmount(m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))))/(SUM(dbo.udfConsumerTransportTotalFee(m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))) - SUM(dbo.udfConsumerTransportDiscountedFee(m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))) * 100 ELSE 0.0 END
     

FROM StudentGradeDivisionMapping M
     INNER JOIN Student S
     ON M.StudentId = S.StudentId
	 INNER JOIN Grade g
	 ON m.GradeId =g.gradeId 	
	 LEFT JOIN [UserRole] ur
	 ON ur.RefId = s.StudentId AND ur.RoleId = 5	

WHERE M.AcademicYearId = @AcademicYearId AND m.IsDeleted<>1 AND s.IsDeleted <> 1 
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