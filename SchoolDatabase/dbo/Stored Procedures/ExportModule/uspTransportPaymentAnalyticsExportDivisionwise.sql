-- =============================================
-- Author:    Shambala Apugade
-- Create date: 28/05/2024
-- Description:  This stored procedure is used to get Payment Analytics Export for Student
-- =============================================
CREATE PROC [dbo].[uspTransportPaymentAnalyticsExportDivisionwise](@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT
		
	g.GradeName,d.DivisionName, m.RollNumber, s.FirstName + ' ' +s.MiddleName + ' ' + s.LastName AS Studentname,	
	TransportTotalFee=  dbo.udfConsumerTransportTotalFee(m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)),
	TransportDiscountedFee = dbo.udfConsumerTransportDiscountedFee(m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5)),
	TransportCollectionTillDate =dbo.udfConsumerTransportPaidAmount(m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5)) + dbo.udfConsumerTransportOtherPaidAmount(m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5)),
	TransportEffectiveFee = dbo.udfConsumerTransportTotalFee(m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5)) - dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5)),
	TransportReceivableFee = dbo.udfConsumerTransportTotalFee (m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5)) - dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5)) - (dbo.udfConsumerTransportPaidAmount(m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5)))+ (dbo.udfConsumerTransportOtherPaidAmount(m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5))),
	TransportCollectionInPercentage =  CASE WHEN dbo.udfConsumerTransportTotalFee (m.AcademicYearId,s.StudentId,  ISNULL(ur.RoleId,5)) - dbo.udfConsumerTransportDiscountedFee(m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5)) > 0  THEN (dbo.udfConsumerTransportPaidAmount(m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5)) + dbo.udfConsumerTransportOtherPaidAmount(m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))/(dbo.udfConsumerTransportTotalFee(m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)) - dbo.udfConsumerTransportDiscountedFee(m.AcademicYearId, s.StudentId,  ISNULL(ur.RoleId,5))) * 100 ELSE 0.0 END,

	s.EmergencyContactNumber AS ContactNo
  	 
FROM StudentGradeDivisionMapping M
     INNER JOIN Student S
     ON M.StudentId = S.StudentId
	 INNER JOIN Grade g
	 ON m.GradeId =g.gradeId
	 INNER JOIN Division d
     ON m.DivisionId = d.DivisionId	
	 LEFT JOIN [UserRole] ur
	 ON ur.RefId = s.StudentId AND ur.RoleId = 5				 	 
WHERE m.AcademicYearId = @AcademicYearId and m.GradeId = @GradeId And m.DivisionId= @DivisionId AND m.IsDeleted <>1 AND s.IsDeleted <> 1 


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