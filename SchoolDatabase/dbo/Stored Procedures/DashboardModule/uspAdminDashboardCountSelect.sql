-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 28/04/2024
-- Description:  This stored procedure is used to get admin dashboard counts
-- =============================================

CREATE PROC uspAdminDashboardCountSelect(@AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 


DECLARE @TodaysAddmissions SMALLINT
DECLARE @MonthlyAddmissions SMALLINT
DECLARE @TillDateAddmissions SMALLINT

--Today's Admission %

SELECT @TodaysAddmissions = COUNT(CASE WHEN s.IsNewStudent = 1 THEN 1 ELSE 0 END) 
FROM dbo.Student s INNER JOIN
dbo.StudentGradeDivisionMapping M
ON m.StudentId = s.StudentId 
WHERE s.DateOfAdmission  =CAST(GETDATE() AS Date) AND s.IsDeleted <> 1 AND
m.AcademicYearId = @AcademicYearId AND s.IsArchive <> 1 and m.IsDeleted <> 1

--Till Date Attendance in AY
 
SELECT @TillDateAddmissions = COUNT(s.IsNewStudent) FROM dbo.Student s 
INNER JOIN dbo.StudentGradeDivisionMapping m
ON m.StudentId = s.StudentId 
WHERE s.IsNewStudent = 1 AND m.AcademicYearId=@AcademicYearId AND 
s.IsDeleted <> 1 AND s.IsArchive <> 1  and m.IsDeleted <> 1

--Current Month Attendance%

SELECT @MonthlyAddmissions = COUNT(CASE WHEN s.IsNewStudent = 1 THEN 1 ELSE 0 END) FROM dbo.Student s INNER JOIN
dbo.StudentGradeDivisionMapping M
ON m.StudentId = s.StudentId 
WHERE s.DateOfAdmission >= CAST(DATEADD(DD,-(DAY(GETDATE() -1)), GETDATE()) AS DATE)
AND s.DateOfAdmission <=  CAST(DATEADD(DD,-(DAY(GETDATE())), DATEADD(MM, 1, GETDATE())) AS DATE) AND 
m.AcademicYearId=@AcademicYearId AND 
s.IsDeleted <> 1 AND s.IsArchive <> 1 and m.IsDeleted <> 1  and m.IsDeleted <> 1;

SELECT @TodaysAddmissions AS TodaysAddmissions, @MonthlyAddmissions AS MonthlyAddmissions, @TillDateAddmissions AS TillDateAddmissions

DECLARE @TodaysAttendance decimal(18,2)
DECLARE @MonthlyAttendance decimal(18,2)
DECLARE @TillDateAttendance decimal(18,2)
--Today's Attendance %

SELECT @TodaysAttendance = ISNULL(SUM(CASE WHEN StatusId =1 THEN 1 
        WHEN StatusId = 2 THEN 0.50 ELSE 0 END)/ COUNT(StudentAttendanceId) * 100,0) 
FROM dbo.StudentAttendance 
WHERE AttendanceDateTime = CAST(GETDATE() AS Date) AND
     AcademicYearId = @AcademicYearId and IsDeleted <> 1

--Till Date Attendance in AY

SELECT @TillDateAttendance = SUM(CASE WHEN StatusId = 1 THEN 1  
WHEN StatusId = 2 THEN 0.50 ELSE 0 END)  / COUNT(StudentAttendanceId) * 100 
FROM dbo.StudentAttendance 
WHERE AcademicYearId = @AcademicYearId and IsDeleted <> 1

--Current Month Attendance%

SELECT @MonthlyAttendance = ISNULL(SUM(CASE WHEN StatusId = 1 THEN 1  
WHEN StatusId = 2 THEN 0.50 ELSE 0 END)  / count(StudentAttendanceId) * 100,0) 
FROM dbo.StudentAttendance 
WHERE AttendanceDateTime >=  CAST(DATEADD(DD,-(DAY(GETDATE() -1)), GETDATE()) AS DATE)
AND AttendanceDateTime <=  CAST(DATEADD(DD,-(DAY(GETDATE())), DATEADD(MM, 1, GETDATE())) AS DATE)
AND AcademicYearId = @AcademicYearId  and IsDeleted <> 1

SELECT @TodaysAttendance AS TodaysAttendance, @MonthlyAttendance AS MonthlyAttendance, @TillDateAttendance AS TillDateAttendance

--Get Girl & Boys Count
DECLARE @TotalCount INT, @GirlsCount INT, @BoysCount INT;
SELECT
@TotalCount = COUNT(s.StudentId)
FROM dbo.Student s INNER JOIN
dbo.StudentGradeDivisionMapping M
ON m.StudentId = s.StudentId 
WHERE s.IsDeleted <> 1 AND m.AcademicYearId = @AcademicYearId and s.IsArchive <> 1 and m.IsDeleted <> 1

SELECT
@GirlsCount = COUNT(s.StudentId)
FROM dbo.Student s INNER JOIN
dbo.StudentGradeDivisionMapping M
ON m.StudentId = s.StudentId 
WHERE s.IsDeleted <> 1 AND m.AcademicYearId = @AcademicYearId and s.IsArchive <> 1 and m.IsDeleted <> 1 AND s.Gender = 'F'


SELECT
@BoysCount = COUNT(s.StudentId)
FROM dbo.Student s INNER JOIN
dbo.StudentGradeDivisionMapping M
ON m.StudentId = s.StudentId 
WHERE s.IsDeleted <> 1 AND m.AcademicYearId = @AcademicYearId and s.IsArchive <> 1 and m.IsDeleted <> 1 AND s.Gender = 'M'

SELECT @TotalCount AS TotalCount, @GirlsCount AS GirlsCount, @BoysCount AS BoysCount

DECLARE @TodaysCollection decimal(18,2)
DECLARE @MonthlyCollection decimal(18,2)
DECLARE @TillDateCollection decimal(18,2)


SELECT @TodaysCollection = ISNULL(SUM(feeDetail.PaidAmount),0)
FROM dbo.FeeParticular F
INNER JOIN dbo.FeePaymentDetails feeDetail 
ON feeDetail.AcademicYearId = @AcademicYearId AND 
feeDetail.FeeParticularId > 0 
AND feeDetail.IsDeleted <> 1
AND feeDetail.FeeParticularId = F.FeeParticularId
WHERE F.AcademicYearId = @AcademicYearId AND ISNULL(F.IsPublished,0) = 1 AND F.IsDeleted <> 1 
AND feeDetail.IsDeleted <> 1 
AND CAST(feeDetail.CreatedDate AS Date) = CAST(GETDATE() AS Date)


SELECT @MonthlyCollection = ISNULL(SUM(feeDetail.PaidAmount),0)
FROM dbo.FeeParticular F
INNER JOIN dbo.FeePaymentDetails feeDetail 
ON feeDetail.AcademicYearId = @AcademicYearId AND 
feeDetail.FeeParticularId > 0 
AND feeDetail.IsDeleted <> 1  
AND feeDetail.FeeParticularId = F.FeeParticularId
WHERE F.AcademicYearId = @AcademicYearId AND ISNULL(F.IsPublished,0) = 1 AND F.IsDeleted <> 1 
AND feeDetail.IsDeleted <> 1 
AND feeDetail.CreatedDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, getDate())    , 0)
     AND feeDetail.CreatedDate <  DATEADD(MONTH, DATEDIFF(MONTH, 0, getDate()) + 1, 0);

SELECT @TillDateCollection = ISNULL(SUM(feeDetail.PaidAmount),0)
FROM dbo.FeeParticular F
INNER JOIN dbo.FeePaymentDetails feeDetail 
ON feeDetail.AcademicYearId = @AcademicYearId AND 
feeDetail.FeeParticularId > 0 
AND feeDetail.IsDeleted <> 1
AND feeDetail.FeeParticularId = F.FeeParticularId
WHERE F.AcademicYearId = @AcademicYearId AND ISNULL(F.IsPublished,0) = 1 AND F.IsDeleted <> 1 
AND feeDetail.IsDeleted <> 1 


SELECT @TodaysCollection AS TodaysCollection, @MonthlyCollection AS MonthlyCollection, @TillDateCollection AS TillDateCollection


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
 