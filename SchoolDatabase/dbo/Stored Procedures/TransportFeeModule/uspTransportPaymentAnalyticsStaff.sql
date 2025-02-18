-- =============================================
-- Author:    Shambala Apugade
-- Create date: 27/05/2024
-- Description:  This stored procedure is used to get Payment Analytics for Student
-- =============================================
CREATE PROC [dbo].[uspTransportPaymentAnalyticsStaff](@AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

DECLARE @SchoolName NVARCHAR(MAX)
SELECT Top 1 @SchoolName = SchoolName FROM School

SELECT 
	@SchoolName AS SchoolName,
	
	TransportTotalFee=  SUM(dbo.udfConsumerTransportTotalFee (t.AcademicYearId, t.ConsumerId, t.RoleId)),
	TransportDiscountedFee = SUM(dbo.udfConsumerTransportDiscountedFee (t.AcademicYearId, t.ConsumerId, t.RoleId)),
	TransportCollectionTillDate = SUM(dbo.udfConsumerTransportPaidAmount (t.AcademicYearId, t.ConsumerId, t.RoleId))+ SUM(dbo.udfConsumerTransportOtherPaidAmount (t.AcademicYearId, t.ConsumerId, t.RoleId)),
	TransportEffectiveFee = SUM(dbo.udfConsumerTransportTotalFee (t.AcademicYearId, t.ConsumerId, t.RoleId))- SUM(dbo.udfConsumerTransportDiscountedFee (t.AcademicYearId, t.ConsumerId, t.RoleId)),
	TransportReceivableFee = (SUM(dbo.udfConsumerTransportTotalFee (t.AcademicYearId, t.ConsumerId, t.RoleId))- SUM(dbo.udfConsumerTransportDiscountedFee (t.AcademicYearId, t.ConsumerId, t.RoleId))) - ( SUM(dbo.udfConsumerTransportPaidAmount (t.AcademicYearId, t.ConsumerId, t.RoleId))+SUM(dbo.udfConsumerTransportOtherPaidAmount(t.AcademicYearId, t.ConsumerId, t.RoleId))),
	TransportCollectionInPercentage = CASE WHEN (SUM(dbo.udfConsumerTransportTotalFee (t.AcademicYearId, t.ConsumerId, t.RoleId)) - SUM(dbo.udfConsumerTransportDiscountedFee (t.AcademicYearId, t.ConsumerId, t.RoleId))) > 0  THEN (SUM(dbo.udfConsumerTransportPaidAmount(t.AcademicYearId, t.ConsumerId, t.RoleId)) + SUM(dbo.udfConsumerTransportOtherPaidAmount(t.AcademicYearId, t.ConsumerId, t.RoleId)))/(SUM(dbo.udfConsumerTransportTotalFee(t.AcademicYearId, t.ConsumerId, t.RoleId)) - SUM(dbo.udfConsumerTransportDiscountedFee(t.AcademicYearId, t.ConsumerId, t.RoleId))) * 100 ELSE 0.0 END
 
FROM TransportConsumerStoppageMapping t
WHERE t.AcademicYearId = @AcademicYearId AND t.RoleId <> 5

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