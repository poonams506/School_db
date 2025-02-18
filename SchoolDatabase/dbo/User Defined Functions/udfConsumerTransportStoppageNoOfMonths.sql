CREATE FUNCTION udfConsumerTransportStoppageNoOfMonths (@AcademicYearId SMALLINT, @ConsumerId BIGINT, @RoleId SMALLINT, @FromDate DATETIME, @ToDate DATETIME, @TransportConsumerStoppageMappingId INT)
RETURNS MONEY AS
BEGIN
          DECLARE @NumberOfMonth INT =0;
          DECLARE @Month1 MONEY = 0;
          DECLARE @Month2 MONEY = 0;


            IF YEAR(@ToDate) > Year(@FromDate)
            BEGIN
                DECLARE @startdateCY DATE = @FromDate, @enddateCY DATE = DATEFROMPARTS(YEAR(@FromDate), 12, 31)
                DECLARE @startdateBY DATE = DATEFROMPARTS(YEAR(GETDATE())+1, 01, 01), @enddateBY DATE = @ToDate

               SELECT @Month1 = (count(a.number))
               FROM (VALUES(1,'Jan'),(2,'Feb'),(3,'Mar'),(4,'Apr'),(5,'May'),(6,'Jun'),(7,'Jul'),
               (8,'Aug'),(9,'Sep'),(10,'Oct'),(11,'Nov'),(12,'Dec')) a(number,months)
               WHERE a.number >= DATEPART(month,@startdateCY) AND a.number <= DATEPART(month,@enddateCY)
                AND a.number in (SELECT s.MonthId FROM SchoolTransportSetting s WHERE s.AcademicYearId = @AcademicYearId AND s.IsDeleted <> 1)
               
                  SELECT @Month2 = (count(a.number))
               FROM (VALUES(1,'Jan'),(2,'Feb'),(3,'Mar'),(4,'Apr'),(5,'May'),(6,'Jun'),(7,'Jul'),
               (8,'Aug'),(9,'Sep'),(10,'Oct'),(11,'Nov'),(12,'Dec')) a(number,months)
               WHERE a.number >= DATEPART(month,@startdateBY) AND a.number <= DATEPART(month,@enddateBY)
                  AND a.number in (SELECT s.MonthId FROM SchoolTransportSetting s WHERE s.AcademicYearId = @AcademicYearId AND s.IsDeleted <> 1)


            END
            ELSE IF YEAR(@ToDate) = Year(@FromDate)
            BEGIN
               SELECT @Month1 = (count(a.number)) 
               FROM (VALUES(1,'Jan'),(2,'Feb'),(3,'Mar'),(4,'Apr'),(5,'May'),(6,'Jun'),(7,'Jul'),
               (8,'Aug'),(9,'Sep'),(10,'Oct'),(11,'Nov'),(12,'Dec')) a(number,months)
               INNER JOIN SchoolTransportSetting s ON a.number = s.MonthId and s.AcademicYearId = @AcademicYearId AND s.IsDeleted <> 1
               WHERE a.number >= DATEPART(month,@FromDate) AND a.number <= DATEPART(month,@ToDate)
               AND a.number in (SELECT s.MonthId FROM SchoolTransportSetting s WHERE s.AcademicYearId = @AcademicYearId AND s.IsDeleted <> 1)
            END
            SET @NumberOfMonth = @Month1 + @Month2;
          RETURN @NumberOfMonth;

END;