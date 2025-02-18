-- =============================================
-- Author:    Deepak Walunj
-- Create date: 17/09/2023
-- Description:  This stored procedure is used to get Fee Payment Month Master data
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportFeePaymentMonthMastersSelect]
	@AcademicYearId SMALLINT,
	@ConsumerId BIGINT,
    @TransportConsumerStoppageMappingId INT,
	@RoleId INT
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
  
          DECLARE @MonthMaster Table(
          MonthMasterId INT,
          MonthMasterName NVARCHAR(100),
		  SortOrder SMALLINT
          )
          DECLARE @MonthMasterSchoolRaw Table(
          MonthMasterId INT,
          MonthMasterName NVARCHAR(100)
          )
          DECLARE @MonthMasterSchool Table(
          MonthMasterId INT,
          MonthMasterName NVARCHAR(100)
          )
          DECLARE @NumberOfMonth INT =0;
          DECLARE @PerMonthAmount MONEY =0;
          DECLARE @StartDate DATE, @ToDate DATE;

          SET @StartDate = (SELECT F.FromDate
                  FROM TransportConsumerStoppageMapping F
                  WHERE F.AcademicYearId = @AcademicYearId AND F.ConsumerId = @ConsumerId AND F.RoleId = @RoleId AND F.IsDeleted <> 1 AND F.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId);

          SET @ToDate = (SELECT F.ToDate
                  FROM TransportConsumerStoppageMapping F
                  WHERE F.AcademicYearId = @AcademicYearId AND F.ConsumerId = @ConsumerId AND F.RoleId = @RoleId AND F.IsDeleted <> 1 AND F.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId);

          SET @PerMonthAmount = (SELECT PickDropPrice
                  FROM TransportConsumerStoppageMapping F
                  WHERE F.AcademicYearId = @AcademicYearId AND F.ConsumerId = @ConsumerId AND F.RoleId = @RoleId AND F.IsDeleted <> 1 AND F.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId);

         IF YEAR(@ToDate) > Year(@StartDate)
         BEGIN
             DECLARE @startdateCY DATE = @StartDate, @enddateCY DATE = DATEFROMPARTS(YEAR(@StartDate), 12, 31)
             DECLARE @startdateBY DATE = DATEFROMPARTS(YEAR(GETDATE())+1, 01, 01), @enddateBY DATE = @ToDate

            INSERT INTO @MonthMaster
            SELECT a.number, a.months, 1
            FROM (VALUES(1,'Jan '+ FORMAT(@startdateCY, 'yy')),(2,'Feb '+ FORMAT(@startdateCY, 'yy')),(3,'Mar '+ FORMAT(@startdateCY, 'yy')),(4,'Apr '+ FORMAT(@startdateCY, 'yy')),
            (5,'May '+ FORMAT(@startdateCY, 'yy')),(6,'Jun '+ FORMAT(@startdateCY, 'yy')),(7,'Jul '+ FORMAT(@startdateCY, 'yy')),
            (8,'Aug '+ FORMAT(@startdateCY, 'yy')),(9,'Sep '+ FORMAT(@startdateCY, 'yy')),(10,'Oct '+ FORMAT(@startdateCY, 'yy')),(11,'Nov '+ FORMAT(@startdateCY, 'yy')),(12,'Dec '+ FORMAT(@startdateCY, 'yy'))) a(number,months)
            WHERE a.number >= DATEPART(month,@startdateCY) AND a.number <= DATEPART(month,@enddateCY)
            
            INSERT INTO @MonthMaster
            SELECT a.number, a.months, 2
             FROM (VALUES(1,'Jan '+ FORMAT(@startdateBY, 'yy')),(2,'Feb '+ FORMAT(@startdateBY, 'yy')),(3,'Mar '+ FORMAT(@startdateBY, 'yy')),(4,'Apr '+ FORMAT(@startdateBY, 'yy')),
            (5,'May '+ FORMAT(@startdateBY, 'yy')),(6,'Jun '+ FORMAT(@startdateBY, 'yy')),(7,'Jul '+ FORMAT(@startdateBY, 'yy')),
            (8,'Aug '+ FORMAT(@startdateBY, 'yy')),(9,'Sep '+ FORMAT(@startdateBY, 'yy')),(10,'Oct '+ FORMAT(@startdateBY, 'yy')),(11,'Nov '+ FORMAT(@startdateBY, 'yy')),(12,'Dec '+ FORMAT(@startdateBY, 'yy'))) a(number,months)
            WHERE a.number >= DATEPART(month,@startdateBY) AND a.number <= DATEPART(month,@enddateBY)

         END
         ELSE IF YEAR(@ToDate) = Year(@StartDate)
         BEGIN
            INSERT INTO @MonthMaster
            SELECT a.number, a.months, 1
             FROM (VALUES(1,'Jan '+ FORMAT(@StartDate, 'yy')),(2,'Feb '+ FORMAT(@StartDate, 'yy')),(3,'Mar '+ FORMAT(@StartDate, 'yy')),(4,'Apr '+ FORMAT(@StartDate, 'yy')),
            (5,'May '+ FORMAT(@StartDate, 'yy')),(6,'Jun '+ FORMAT(@StartDate, 'yy')),(7,'Jul '+ FORMAT(@StartDate, 'yy')),
            (8,'Aug '+ FORMAT(@StartDate, 'yy')),(9,'Sep '+ FORMAT(@StartDate, 'yy')),(10,'Oct '+ FORMAT(@StartDate, 'yy')),(11,'Nov '+ FORMAT(@StartDate, 'yy')),(12,'Dec '+ FORMAT(@StartDate, 'yy'))) a(number,months)
            WHERE a.number >= DATEPART(month,@StartDate) AND a.number <= DATEPART(month,@ToDate)
         END

           
           DECLARE @AcademicYearStartDate DATE = (SELECT AcademicYearStartMonth FROM SchoolSetting WHERE AcademicYearId = @AcademicYearId)  -- Replace with your start date

            ;WITH Months AS (
                SELECT @AcademicYearStartDate AS DateValue
                UNION ALL
                SELECT DATEADD(MONTH, 1, DateValue)
                FROM Months
                WHERE DATEADD(MONTH, 1, DateValue) <= DATEADD(MONTH, 11, @AcademicYearStartDate)
            )
            INSERT INTO @MonthMasterSchoolRaw
            SELECT MONTH(DateValue) AS MonthMasterId, FORMAT(DateValue, 'MMM yy') AS MonthMasterName
            FROM Months
            OPTION (MAXRECURSION 12);

          INSERT INTO @MonthMasterSchool
          SELECT r.MonthMasterId, r.MonthMasterName
          FROM @MonthMasterSchoolRaw r
          JOIN SchoolTransportSetting s ON r.MonthMasterId = s.MonthId and s.AcademicYearId = @AcademicYearId AND s.IsDeleted <> 1

          SELECT m.MonthMasterId,m.MonthMasterName, @PerMonthAmount AS PerMonthAmount
          FROM @MonthMaster m
          JOIN @MonthMasterSchool ms
          ON m.MonthMasterId = ms.MonthMasterId
		  ORDER BY m.SortOrder, m.MonthMasterId
		
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
@ErrorState END CATCH End