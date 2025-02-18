-- =============================================
-- Author:    Shambala Apugade
-- Create date: 22/06/2024
-- Description:  This stored procedure is used to get shared transport school info 
-- =============================================
CREATE PROC dbo.uspCabDriverStoppageStudentSelect(
@RouteId BIGINT,
@AcademicYearId SMALLINT,
@TripType NVARCHAR(10)) 
AS BEGIN
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY 
DECLARE @CurrentDateTime DATETIME = GETDATE();
IF @TripType = 'Pickup'

BEGIN
SELECT 
s.RouteId,
s.StoppageId,
s.StoppageName,
s.OrderNo,
ISNULL(tr.TripId,0) AS TripId
FROM dbo.TransportStoppage s
INNER JOIN dbo.TransportRoute r ON r.RouteId = s.RouteId
OUTER APPLY (SELECT TOP (1) tr.TripId FROM  dbo.Trip tr WHERE s.RouteId=tr.RouteId AND tr.TripType = 'Pickup' AND tr.TripEndTime IS NULL
			AND CAST(tr.TripStartTime AS DATE) = CAST(GETDATE() AS DATE) 
			AND tr.TripEndTime IS NULL ORDER BY tr.TripId DESC) tr
WHERE
s.RouteId = @RouteId AND s.AcademicYearId = @AcademicYearId AND s.IsDeleted <> 1
ORDER BY s.OrderNo

END

ELSE
BEGIN

SELECT 
s.StoppageId,
s.StoppageName,
s.RouteId,
s.OrderNo,
ISNULL(tr.TripId,0) AS TripId
FROM dbo.TransportStoppage s
INNER JOIN dbo.TransportRoute r ON r.RouteId= s.RouteId
OUTER APPLY (SELECT TOP (1) tr.TripId FROM  dbo.Trip tr WHERE s.RouteId=tr.RouteId AND tr.TripType = 'Drop' AND tr.TripEndTime IS NULL
			AND CAST(tr.TripStartTime AS DATE) = CAST(GETDATE() AS DATE) 
			AND tr.TripEndTime IS NULL
			ORDER BY tr.TripId DESC
			) tr
WHERE s.RouteId = @RouteId AND s.AcademicYearId = @AcademicYearId AND s.IsDeleted <> 1
ORDER BY s.OrderNo DESC

END

IF @TripType = 'Pickup'
BEGIN
SELECT t.RouteId,m.StoppageId, m.ConsumerId, m.RoleId, s.StudentId,
       CONCAT(
            COALESCE(s.FirstName + ' ', '')
            , COALESCE(s.MiddleName + ' ', '')
            , COALESCE(s.LastName,'')
        ) AS StudentName,CONCAT(g.GradeName,' - ',d.DivisionName) AS ClassName,
		sgdm.RollNumber,
		CASE WHEN @TripType='Pickup' AND tr.TripId  IS NOT NULL THEN 1 
		ELSE 0 END AS IsAlreadyPickedDropped,s.EmergencyContactNumber
		
FROM dbo.TransportConsumerStoppageMapping m 
INNER JOIN dbo.TransportStoppage t ON t.StoppageId = m.StoppageId
INNER JOIN dbo.Student s ON m.ConsumerId = s.StudentId AND m.RoleId = 5 
INNER JOIN dbo.StudentGradeDivisionMapping sgdm ON s.StudentId=sgdm.StudentId 
						AND sgdm.AcademicYearId=@AcademicYearId
INNER JOIN dbo.Grade g ON sgdm.GradeId=g.GradeId
INNER JOIN dbo.Division d ON sgdm.DivisionId=d.DivisionId 
OUTER APPLY (SELECT TOP (1) tr.TripId FROM dbo.Trip tr INNER JOIN
		   dbo.TripDetail trd ON tr.TripId=trd.TripId AND trd.StudentId=s.StudentId  
		   WHERE  tr.TripType = 'Pickup' AND tr.TripEndTime IS NULL
			AND CAST(tr.TripStartTime AS DATE) = CAST(GETDATE() AS DATE) 
			AND  t.RouteId=tr.RouteId
			AND tr.TripEndTime IS NULL ORDER BY tr.TripId DESC
			) AS tr
WHERE  t.RouteId = @RouteId AND m.AcademicYearId = @AcademicYearId 
      AND m.IsDeleted <>1 AND g.IsDeleted<>1 AND d.IsDeleted<>1
	  AND (m.PickDropId = 1 OR m.PickDropId = 3)
	  AND  CAST(@CurrentDateTime AS DATE) BETWEEN CAST( m.FromDate  AS DATE) AND CAST(m.ToDate  AS DATE)
END

ELSE IF @TripType = 'Drop'
BEGIN
SELECT t.RouteId,m.StoppageId, m.ConsumerId, m.RoleId, s.StudentId,
       CONCAT(
            COALESCE(s.FirstName + ' ', '')
            , COALESCE(s.MiddleName + ' ', '')
            , COALESCE(s.LastName,'')
        ) AS StudentName,CONCAT(g.GradeName,' - ',d.DivisionName) AS ClassName,
		sgdm.RollNumber,
		CASE 
		     WHEN @TripType='Drop' AND tr2.TripId  IS NOT NULL THEN 1 
		ELSE 0 END AS IsAlreadyPickedDropped,s.EmergencyContactNumber
		
FROM dbo.TransportConsumerStoppageMapping m 
INNER JOIN dbo.TransportStoppage t ON t.StoppageId = m.StoppageId
INNER JOIN dbo.Student s ON m.ConsumerId = s.StudentId AND m.RoleId = 5 
INNER JOIN dbo.StudentGradeDivisionMapping sgdm ON s.StudentId=sgdm.StudentId 
						AND sgdm.AcademicYearId=@AcademicYearId
INNER JOIN dbo.Grade g ON sgdm.GradeId=g.GradeId
INNER JOIN dbo.Division d ON sgdm.DivisionId=d.DivisionId 
OUTER APPLY (SELECT TOP (1) tr.TripId FROM dbo.Trip tr INNER JOIN
		   dbo.TripDetail trd ON tr.TripId=trd.TripId AND trd.StudentId=s.StudentId  
		   WHERE  tr.TripType = 'Drop' AND tr.TripEndTime IS NULL
			AND CAST(tr.TripStartTime AS DATE) = CAST(GETDATE() AS DATE) 
			AND  t.RouteId=tr.RouteId 
			AND tr.TripEndTime IS NULL ORDER BY tr.TripId DESC
			)  AS tr2
WHERE  t.RouteId = @RouteId AND m.AcademicYearId = @AcademicYearId 
      AND m.IsDeleted <>1 AND g.IsDeleted<>1 AND d.IsDeleted<>1
	  AND (m.PickDropId = 2 OR m.PickDropId = 3)
	  AND  CAST(@CurrentDateTime AS DATE) BETWEEN CAST( m.FromDate  AS DATE) AND CAST(m.ToDate  AS DATE)
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
@ErrorState END CATCH END
GO
