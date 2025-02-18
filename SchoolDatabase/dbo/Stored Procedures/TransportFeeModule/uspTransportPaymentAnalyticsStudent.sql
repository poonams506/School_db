-- =============================================
-- Author:    Shambala Apugade
-- Create date: 27/05/2024
-- Description:  This stored procedure is used to get Payment Analytics for Student
-- =============================================
CREATE PROC [dbo].[uspTransportPaymentAnalyticsStudent](@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT  
	g.GradeId, d.DivisionId, s.FirstName +' ' + s.MiddleName + ' ' + s.LastName AS Studentname,s.StudentId,
	
	TransportTotalFee=  dbo.udfConsumerTransportTotalFee(m.AcademicYearId, s.StudentId, ISNULL(tm.RoleId,5)),
	TransportDiscountedFee = dbo.udfConsumerTransportDiscountedFee(m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5)),
	TransportCollectionTillDate =dbo.udfConsumerTransportPaidAmount(m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5)) + dbo.udfConsumerTransportOtherPaidAmount(m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5)),
	TransportEffectiveFee = dbo.udfConsumerTransportTotalFee(m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5)) - dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5)),
	TransportReceivableFee = dbo.udfConsumerTransportTotalFee (m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5)) - dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5)) - (dbo.udfConsumerTransportPaidAmount(m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5)))+ (dbo.udfConsumerTransportOtherPaidAmount(m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5))),
	TransportCollectionInPercentage =  CASE WHEN dbo.udfConsumerTransportTotalFee (m.AcademicYearId,s.StudentId,  ISNULL(tm.RoleId,5)) - dbo.udfConsumerTransportDiscountedFee(m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5)) > 0  THEN (dbo.udfConsumerTransportPaidAmount(m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5)) + dbo.udfConsumerTransportOtherPaidAmount(m.AcademicYearId, s.StudentId, ISNULL(tm.RoleId,5)))/(dbo.udfConsumerTransportTotalFee(m.AcademicYearId, s.StudentId, ISNULL(tm.RoleId,5)) - dbo.udfConsumerTransportDiscountedFee(m.AcademicYearId, s.StudentId,  ISNULL(tm.RoleId,5))) * 100 ELSE 0.0 END
  
FROM StudentGradeDivisionMapping M
     INNER JOIN Student S
     ON M.StudentId = S.StudentId
	 INNER JOIN Grade g
	 ON m.GradeId =g.gradeId
	 INNER JOIN Division d
     ON m.DivisionId = d.DivisionId	
	 INNER JOIN TransportConsumerStoppageMapping tm
	 ON tm.ConsumerId = s.StudentId
	 
WHERE m.AcademicYearId = @AcademicYearId AND tm.AcademicYearId = @AcademicYearId AND m.GradeId = @GradeId And m.DivisionId= @DivisionId AND m.IsDeleted <>1 AND s.IsDeleted <> 1 
AND tm.RoleId =5
Group by s.StudentId,g.GradeId, d.DivisionId,s.FirstName, s.MiddleName, s.LastName,m.AcademicYearId,tm.RoleId



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
	