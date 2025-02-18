-- =============================================
-- Author:    Deepa Walunj
-- Create date: 31/08/2023
-- Description:  This stored procedure is used to get Fee payment deatils for grid
-- =============================================
CREATE  PROCEDURE [dbo].[uspTransportFeePaymentStoppageGridSelect]
	@AcademicYearId SMALLINT,
    @ConsumerId INT,
    @RoleId INT
AS
BEGIN
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY

  

  IF @RoleId = 5
  BEGIN
  SELECT dbo.udfConsumerTransportStoppageTotalFee(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'TotalFee',
     dbo.udfConsumerTransportStoppageDiscountedFee(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'DiscountedFee',
     dbo.udfConsumerTransportStoppagePaidAmount(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'PaidAmount',
     dbo.udfConsumerTransportStoppageOtherPaidAmount(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'OtherPaidAmount',
     dbo.udfConsumerTransportStoppageDueAmount(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'DueAmount',
     dbo.udfConsumerTransportStoppageChequeClearedAmount(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'ChequeClearedAmount',
     dbo.udfConsumerTransportStoppageChequeUnClearAmount(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'ChequeUnclearAmount',
	 @ConsumerId AS ConsumerId, @RoleId AS RoleId, @AcademicYearId AS AcademicYearId, transport.PickDropId, transport.PickDropPrice, transport.TransportConsumerStoppageMappingId,
     dbo.udfConsumerTransportStoppageNoOfMonths(@AcademicYearId, @ConsumerId, 5, transport.FromDate, transport.ToDate, transport.TransportConsumerStoppageMappingId) as Months,
     format(transport.FromDate, 'MMM-yy') AS FromDateString, format(transport.ToDate, 'MMM-yy') AS ToDateString, 
     (SELECT tempStoppage.StoppageName FROM TransportStoppage tempStoppage WHERE tempStoppage.StoppageId = transport.StoppageId AND tempStoppage.IsDeleted <> 1 
     AND tempStoppage.AcademicYearId = @AcademicYearId) AS StoppageName,
     (SELECT tempRoute.RouteName FROM TransportRoute tempRoute INNER JOIN TransportStoppage tempStoppage ON tempRoute.RouteId = tempStoppage.RouteId
     WHERE tempStoppage.StoppageId = transport.StoppageId AND tempStoppage.IsDeleted <> 1 AND tempStoppage.AcademicYearId = @AcademicYearId
     AND tempRoute.IsDeleted <> 1 AND tempRoute.AcademicYearId = @AcademicYearId
     ) AS RouteName
  FROM StudentGradeDivisionMapping M
       INNER JOIN Student S
       ON M.StudentId = S.StudentId
       INNER JOIN TransportConsumerStoppageMapping transport
       ON M.StudentId = transport.ConsumerId AND transport.RoleId = 5 AND transport.AcademicYearId = @AcademicYearId
  WHERE
   M.IsDeleted <> 1
   AND S.IsDeleted <> 1
   AND S.IsArchive <> 1
   AND M.StudentId = @ConsumerId
   AND M.AcademicYearId = @AcademicYearId
   AND transport.IsDeleted <> 1
   AND transport.AcademicYearId = @AcademicYearId
  END
  ELSE IF @RoleId = 3
  BEGIN
       SELECT dbo.udfConsumerTransportStoppageTotalFee(@AcademicYearId, M.TeacherId, 3, transport.TransportConsumerStoppageMappingId) AS 'TotalFee',
     dbo.udfConsumerTransportStoppageDiscountedFee(@AcademicYearId, M.TeacherId, 3, transport.TransportConsumerStoppageMappingId) AS 'DiscountedFee',
     dbo.udfConsumerTransportStoppagePaidAmount(@AcademicYearId, M.TeacherId, 3, transport.TransportConsumerStoppageMappingId) AS 'PaidAmount',
     dbo.udfConsumerTransportStoppageOtherPaidAmount(@AcademicYearId, M.TeacherId, 3, transport.TransportConsumerStoppageMappingId) AS 'OtherPaidAmount',
     dbo.udfConsumerTransportStoppageDueAmount(@AcademicYearId, M.TeacherId, 3, transport.TransportConsumerStoppageMappingId) AS 'DueAmount',
     dbo.udfConsumerTransportStoppageChequeClearedAmount(@AcademicYearId, M.TeacherId, 3, transport.TransportConsumerStoppageMappingId) AS 'ChequeClearedAmount',
     dbo.udfConsumerTransportStoppageChequeUnClearAmount(@AcademicYearId, M.TeacherId, 3, transport.TransportConsumerStoppageMappingId) AS 'ChequeUnclearAmount',
	 @ConsumerId AS ConsumerId, @RoleId AS RoleId, @AcademicYearId AS AcademicYearId, transport.PickDropId, transport.PickDropPrice, transport.TransportConsumerStoppageMappingId,
     dbo.udfConsumerTransportStoppageNoOfMonths(@AcademicYearId, @ConsumerId, 3, transport.FromDate, transport.ToDate, transport.TransportConsumerStoppageMappingId) as Months,
     format(transport.FromDate, 'MMM-yy') AS FromDateString, format(transport.ToDate, 'MMM-yy') AS ToDateString, 
     (SELECT tempStoppage.StoppageName FROM TransportStoppage tempStoppage WHERE tempStoppage.StoppageId = transport.StoppageId AND tempStoppage.IsDeleted <> 1 AND tempStoppage.AcademicYearId = @AcademicYearId) AS StoppageName,
     (SELECT tempRoute.RouteName FROM TransportRoute tempRoute INNER JOIN TransportStoppage tempStoppage ON tempRoute.RouteId = tempStoppage.RouteId
     WHERE tempStoppage.StoppageId = transport.StoppageId AND tempStoppage.IsDeleted <> 1 AND tempStoppage.AcademicYearId = @AcademicYearId
     AND tempRoute.IsDeleted <> 1 AND tempRoute.AcademicYearId = @AcademicYearId
     ) AS RouteName
     FROM Teacher M
       INNER JOIN TransportConsumerStoppageMapping transport
       ON M.TeacherId = transport.ConsumerId AND transport.RoleId = 3 AND transport.AcademicYearId = @AcademicYearId
     WHERE
     M.IsDeleted <> 1
     AND M.TeacherId = @ConsumerId
     AND transport.IsDeleted <> 1
     AND transport.AcademicYearId = @AcademicYearId
  END
  ELSE IF @RoleId = 4
  BEGIN
       SELECT dbo.udfConsumerTransportStoppageTotalFee(@AcademicYearId, M.ClerkId, 4, transport.TransportConsumerStoppageMappingId) AS 'TotalFee',
     dbo.udfConsumerTransportStoppageDiscountedFee(@AcademicYearId, M.ClerkId, 4, transport.TransportConsumerStoppageMappingId) AS 'DiscountedFee',
     dbo.udfConsumerTransportStoppagePaidAmount(@AcademicYearId, M.ClerkId, 4, transport.TransportConsumerStoppageMappingId) AS 'PaidAmount',
     dbo.udfConsumerTransportStoppageOtherPaidAmount(@AcademicYearId, M.ClerkId, 4, transport.TransportConsumerStoppageMappingId) AS 'OtherPaidAmount',
     dbo.udfConsumerTransportStoppageDueAmount(@AcademicYearId, M.ClerkId, 4, transport.TransportConsumerStoppageMappingId) AS 'DueAmount',
     dbo.udfConsumerTransportStoppageChequeClearedAmount(@AcademicYearId, M.ClerkId, 4, transport.TransportConsumerStoppageMappingId) AS 'ChequeClearedAmount',
     dbo.udfConsumerTransportStoppageChequeUnClearAmount(@AcademicYearId, M.ClerkId, 4, transport.TransportConsumerStoppageMappingId) AS 'ChequeUnclearAmount',
	 @ConsumerId AS ConsumerId, @RoleId AS RoleId, @AcademicYearId AS AcademicYearId, transport.PickDropId, transport.PickDropPrice, transport.TransportConsumerStoppageMappingId,
     dbo.udfConsumerTransportStoppageNoOfMonths(@AcademicYearId, @ConsumerId, 4, transport.FromDate, transport.ToDate, transport.TransportConsumerStoppageMappingId) as Months,
     format(transport.FromDate, 'MMM-yy') AS FromDateString, format(transport.ToDate, 'MMM-yy') AS ToDateString, 
     (SELECT tempStoppage.StoppageName FROM TransportStoppage tempStoppage WHERE tempStoppage.StoppageId = transport.StoppageId AND tempStoppage.IsDeleted <> 1 AND tempStoppage.AcademicYearId = @AcademicYearId) AS StoppageName,
     (SELECT tempRoute.RouteName FROM TransportRoute tempRoute INNER JOIN TransportStoppage tempStoppage ON tempRoute.RouteId = tempStoppage.RouteId
     WHERE tempStoppage.StoppageId = transport.StoppageId AND tempStoppage.IsDeleted <> 1 AND tempStoppage.AcademicYearId = @AcademicYearId
     AND tempRoute.IsDeleted <> 1 AND tempRoute.AcademicYearId = @AcademicYearId
     ) AS RouteName
     FROM Clerk M
       INNER JOIN TransportConsumerStoppageMapping transport
       ON M.ClerkId = transport.ConsumerId AND transport.RoleId = 4 AND transport.AcademicYearId = @AcademicYearId
     WHERE
     M.IsDeleted <> 1
     AND M.ClerkId = @ConsumerId
     AND transport.IsDeleted <> 1
     AND transport.AcademicYearId = @AcademicYearId
  END
   ELSE IF @RoleId = 6
  BEGIN
       SELECT dbo.udfConsumerTransportStoppageTotalFee(@AcademicYearId, M.CabDriverId, 6, transport.TransportConsumerStoppageMappingId) AS 'TotalFee',
     dbo.udfConsumerTransportStoppageDiscountedFee(@AcademicYearId, M.CabDriverId, 6, transport.TransportConsumerStoppageMappingId) AS 'DiscountedFee',
     dbo.udfConsumerTransportStoppagePaidAmount(@AcademicYearId, M.CabDriverId, 6, transport.TransportConsumerStoppageMappingId) AS 'PaidAmount',
     dbo.udfConsumerTransportStoppageOtherPaidAmount(@AcademicYearId, M.CabDriverId, 6, transport.TransportConsumerStoppageMappingId) AS 'OtherPaidAmount',
     dbo.udfConsumerTransportStoppageDueAmount(@AcademicYearId, M.CabDriverId, 6, transport.TransportConsumerStoppageMappingId) AS 'DueAmount',
     dbo.udfConsumerTransportStoppageChequeClearedAmount(@AcademicYearId, M.CabDriverId, 6, transport.TransportConsumerStoppageMappingId) AS 'ChequeClearedAmount',
     dbo.udfConsumerTransportStoppageChequeUnClearAmount(@AcademicYearId, M.CabDriverId, 6, transport.TransportConsumerStoppageMappingId) AS 'ChequeUnclearAmount',
	 @ConsumerId AS ConsumerId, @RoleId AS RoleId, @AcademicYearId AS AcademicYearId, transport.PickDropId, transport.PickDropPrice, transport.TransportConsumerStoppageMappingId,
     dbo.udfConsumerTransportStoppageNoOfMonths(@AcademicYearId, @ConsumerId, 6, transport.FromDate, transport.ToDate, transport.TransportConsumerStoppageMappingId) as Months,
     format(transport.FromDate, 'MMM-yy') AS FromDateString, format(transport.ToDate, 'MMM-yy') AS ToDateString, 
     (SELECT tempStoppage.StoppageName FROM TransportStoppage tempStoppage WHERE tempStoppage.StoppageId = transport.StoppageId AND tempStoppage.IsDeleted <> 1 AND tempStoppage.AcademicYearId = @AcademicYearId) AS StoppageName,
     (SELECT tempRoute.RouteName FROM TransportRoute tempRoute INNER JOIN TransportStoppage tempStoppage ON tempRoute.RouteId = tempStoppage.RouteId
     WHERE tempStoppage.StoppageId = transport.StoppageId AND tempStoppage.IsDeleted <> 1 AND tempStoppage.AcademicYearId = @AcademicYearId
     AND tempRoute.IsDeleted <> 1 AND tempRoute.AcademicYearId = @AcademicYearId
     ) AS RouteName
     FROM CabDriver M
       INNER JOIN TransportConsumerStoppageMapping transport
       ON M.CabDriverId = transport.ConsumerId AND transport.RoleId = 6 AND transport.AcademicYearId = @AcademicYearId
     WHERE
     M.IsDeleted <> 1
     AND M.CabDriverId = @ConsumerId
     AND transport.IsDeleted <> 1
     AND transport.AcademicYearId = @AcademicYearId
  END
  
 


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