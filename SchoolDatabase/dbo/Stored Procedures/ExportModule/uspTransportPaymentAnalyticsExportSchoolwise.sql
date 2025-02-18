-- =============================================
-- Author:    Shambala Apugade
-- Create date: 28/05/2024
-- Description:  This stored procedure is used to get Payment Analytics for School
-- =============================================
CREATE PROC [dbo].[uspTransportPaymentAnalyticsExportSchoolWise] (@AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT 

	sc.SchoolName,
	g.GradeName,d.DivisionName,m.RollNumber, s.FirstName + ' ' + s.MiddleName +' '+ s.LastName AS 'StudentName',
	
TransportTotalFee=  SUM(dbo.udfConsumerTransportTotalFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))),
TransportDiscountedFee = SUM(dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))),
TransportCollectionTillDate =SUM(dbo.udfConsumerTransportPaidAmount (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))+SUM(dbo.udfConsumerTransportOtherPaidAmount (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))),
TransportEffectiveFee = SUM(dbo.udfConsumerTransportTotalFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))- SUM(dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))),
TransportReceivableFee = (SUM(dbo.udfConsumerTransportTotalFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))- SUM(dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))) - ( SUM(dbo.udfConsumerTransportPaidAmount (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))+SUM(dbo.udfConsumerTransportOtherPaidAmount (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))),
TransportCollectionInPercentage = CASE WHEN (SUM(dbo.udfConsumerTransportTotalFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))) - SUM(dbo.udfConsumerTransportDiscountedFee (m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))) > 0  THEN (SUM(dbo.udfConsumerTransportPaidAmount(m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))) + SUM(dbo.udfConsumerTransportOtherPaidAmount(m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))))/(SUM(dbo.udfConsumerTransportTotalFee(m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5))) - SUM(dbo.udfConsumerTransportDiscountedFee(m.AcademicYearId, s.StudentId, ISNULL(ur.RoleId,5)))) * 100 ELSE 0.0 END,
     
	s.EmergencyContactNumber AS ContactNo
	
FROM StudentGradeDivisionMapping M
     INNER JOIN Student S
     ON M.StudentId = S.StudentId
	 INNER JOIN School sc
	 ON sc.SchoolId=s.SchoolId
	 INNER JOIN Grade g
	 ON m.GradeId =g.gradeId
	 INNER JOIN Division d
	 ON m.DivisionId=d.DivisionId
	 LEFT JOIN [UserRole] ur
	 ON ur.RefId = s.StudentId AND ur.RoleId = 5	
		
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

