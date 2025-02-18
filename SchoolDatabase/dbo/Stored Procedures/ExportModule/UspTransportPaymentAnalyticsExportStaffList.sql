-- =============================================
-- Author:    Shambala Apugade
-- Create date: 29/05/2024
-- Description:  This stored procedure is used to get Payment Analytics Export for Student
-- =============================================
CREATE PROC [dbo].[uspTransportPaymentAnalyticsExportStaffList](@AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

DECLARE @TransportStaffTempTable TABLE(
  RoleId INT,
  ConsumerName NVARCHAR(100),
  RoleName NVARCHAR(50),
  AcademicYearName NVARCHAR(50),
  TransportTotalFee MONEY,
  TransportDiscountedFee MONEY,
  TransportCollectionTillDate MONEY,
  TransportEffectiveFee MONEY,
  TransportReceivableFee MONEY,
  TransportCollectionInPercentage MONEY,
  ContactNo NVARCHAR(20) )

---TEACHER
INSERT INTO @TransportStaffTempTable 

SELECT	
		3 AS RoleId, T.FirstName + ' '+ T.MiddleName + ' ' + T.LastName AS ConsumerName, 'Teacher' AS RoleName,a.AcademicYearName,
		dbo.udfConsumerTransportTotalFee(@AcademicYearId, T.TeacherId, 3) AS 'TotalFee',
		dbo.udfConsumerTransportDiscountedFee(@AcademicYearId, T.TeacherId, 3) AS 'DiscountedFee',
		dbo.udfConsumerTransportPaidAmount (@AcademicYearId, T.TeacherId, 3) + dbo.udfConsumerTransportOtherPaidAmount (@AcademicYearId, T.TeacherId, 3) AS 'TransportCollectionTillDate',
		dbo.udfConsumerTransportTotalFee (@AcademicYearId, T.TeacherId, 3) - dbo.udfConsumerTransportDiscountedFee (@AcademicYearId, T.TeacherId, 3) AS 'TransportEffectiveFee',
		(dbo.udfConsumerTransportTotalFee (@AcademicYearId, T.TeacherId, 3))- (dbo.udfConsumerTransportDiscountedFee (@AcademicYearId, T.TeacherId, 3)) - (dbo.udfConsumerTransportPaidAmount (@AcademicYearId, T.TeacherId, 3)+ dbo.udfConsumerTransportOtherPaidAmount(@AcademicYearId, T.TeacherId, 3)) AS 'TransportReceivableFee',
		CASE WHEN (dbo.udfConsumerTransportTotalFee (@AcademicYearId, T.TeacherId, 3) 
		- dbo.udfConsumerTransportDiscountedFee (@AcademicYearId, T.TeacherId, 3)) > 0  
		THEN ((dbo.udfConsumerTransportPaidAmount(@AcademicYearId, T.TeacherId, 3) 
		+ dbo.udfConsumerTransportOtherPaidAmount(@AcademicYearId, T.TeacherId, 3))
		/ (dbo.udfConsumerTransportTotalFee(@AcademicYearId, T.TeacherId, 3)
		- dbo.udfConsumerTransportDiscountedFee(@AcademicYearId, T.TeacherId, 3))) * 100
		ELSE 0.0 END AS 'TransportCollectionInPercentage',
		T.MobileNumber AS 'ContactNo'
 
FROM 
	TransportConsumerStoppageMapping M
	INNER JOIN Teacher T
    ON M.ConsumerId = T.TeacherId AND M.RoleId = 3
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = m.AcademicYearId
WHERE
	 M.IsDeleted <> 1
	 AND T.IsDeleted <> 1
	 AND M.AcademicYearId = @AcademicYearId
	 AND M.RoleId = 3

UNION 
--- CLERK
SELECT	
		4 AS RoleId, T.FirstName + ' '+ T.MiddleName + ' ' + T.LastName AS ConsumerName, 'Clerk' AS RoleName,a.AcademicYearName,
		dbo.udfConsumerTransportTotalFee(@AcademicYearId, T.ClerkId, 4) AS 'TotalFee',
		dbo.udfConsumerTransportDiscountedFee(@AcademicYearId, T.ClerkId, 4) AS 'DiscountedFee',
		dbo.udfConsumerTransportPaidAmount (@AcademicYearId, T.ClerkId, 4) + dbo.udfConsumerTransportOtherPaidAmount (@AcademicYearId, T.ClerkId, 4) AS 'TransportCollectionTillDate',
		dbo.udfConsumerTransportTotalFee (@AcademicYearId, T.ClerkId, 4) - dbo.udfConsumerTransportDiscountedFee (@AcademicYearId, T.ClerkId, 4) AS 'TransportEffectiveFee',
		(dbo.udfConsumerTransportTotalFee (@AcademicYearId, T.ClerkId, 4))- (dbo.udfConsumerTransportDiscountedFee (@AcademicYearId, T.ClerkId, 4)) - (dbo.udfConsumerTransportPaidAmount (@AcademicYearId, T.ClerkId, 4)+ dbo.udfConsumerTransportOtherPaidAmount(@AcademicYearId, T.ClerkId, 4)) AS 'TransportReceivableFee',
		CASE WHEN (dbo.udfConsumerTransportTotalFee (@AcademicYearId, T.ClerkId, 4) 
		- dbo.udfConsumerTransportDiscountedFee (@AcademicYearId, T.ClerkId, 4)) > 0  
		THEN ((dbo.udfConsumerTransportPaidAmount(@AcademicYearId, T.ClerkId, 4) 
		+ dbo.udfConsumerTransportOtherPaidAmount(@AcademicYearId, T.ClerkId, 4))
		/ (dbo.udfConsumerTransportTotalFee(@AcademicYearId, T.ClerkId, 4)
		- dbo.udfConsumerTransportDiscountedFee(@AcademicYearId, T.ClerkId, 4))) * 100
		ELSE 0.0 END AS 'TransportCollectionInPercentage',
		T.MobileNumber AS 'ContactNo'
 
FROM 
	TransportConsumerStoppageMapping M
	INNER JOIN Clerk T
    ON M.ConsumerId = T.ClerkId  AND M.RoleId = 4
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = m.AcademicYearId
WHERE
	 M.IsDeleted <> 1
	 AND T.IsDeleted <> 1
	 AND M.AcademicYearId = @AcademicYearId
	 AND M.RoleId = 4

UNION
--- CAB DRIVER

SELECT	
		6 AS RoleId, T.FirstName + ' '+ T.MiddleName + ' ' + T.LastName AS ConsumerName, 'Cab Driver' AS RoleName,a.AcademicYearName,
		dbo.udfConsumerTransportTotalFee(@AcademicYearId, T.CabDriverId, 6) AS 'TotalFee',
		dbo.udfConsumerTransportDiscountedFee(@AcademicYearId, T.CabDriverId, 6) AS 'DiscountedFee',
		dbo.udfConsumerTransportPaidAmount (@AcademicYearId, T.CabDriverId, 6) + dbo.udfConsumerTransportOtherPaidAmount (@AcademicYearId, T.CabDriverId, 6) AS 'TransportCollectionTillDate',
		dbo.udfConsumerTransportTotalFee (@AcademicYearId, T.CabDriverId, 6) - dbo.udfConsumerTransportDiscountedFee (@AcademicYearId, T.CabDriverId, 6) AS 'TransportEffectiveFee',
		(dbo.udfConsumerTransportTotalFee (@AcademicYearId, T.CabDriverId, 6))- (dbo.udfConsumerTransportDiscountedFee (@AcademicYearId, T.CabDriverId, 6)) - (dbo.udfConsumerTransportPaidAmount (@AcademicYearId, T.CabDriverId, 6)+ dbo.udfConsumerTransportOtherPaidAmount(@AcademicYearId, T.CabDriverId, 6)) AS 'TransportReceivableFee',
		CASE WHEN (dbo.udfConsumerTransportTotalFee (@AcademicYearId, T.CabDriverId, 6) 
		- dbo.udfConsumerTransportDiscountedFee (@AcademicYearId, T.CabDriverId, 6)) > 0  
		THEN ((dbo.udfConsumerTransportPaidAmount(@AcademicYearId, T.CabDriverId, 6) 
		+ dbo.udfConsumerTransportOtherPaidAmount(@AcademicYearId, T.CabDriverId, 6))
		/ (dbo.udfConsumerTransportTotalFee(@AcademicYearId, T.CabDriverId, 6)
		- dbo.udfConsumerTransportDiscountedFee(@AcademicYearId, T.CabDriverId, 6))) * 100
		ELSE 0.0 END AS 'TransportCollectionInPercentage',
		T.MobileNumber AS 'ContactNo'
 
FROM 
	TransportConsumerStoppageMapping M
	INNER JOIN CabDriver T
    ON M.ConsumerId = T.CabDriverId  AND M.RoleId = 6
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = m.AcademicYearId
WHERE
	 M.IsDeleted <> 1
	 AND T.IsDeleted <> 1
	 AND M.AcademicYearId = @AcademicYearId
	 AND M.RoleId = 6

SELECT * FROM @TransportStaffTempTable


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