CREATE PROCEDURE [dbo].[uspConsumerMappingSelectByStoppageId](
@AcademicYearId SMALLINT,
@StoppageId INT,
@ConsumerName NVARCHAR(150)=NULL
) AS BEGIN
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY  


 SELECT tcsm.TransportConsumerStoppageMappingId,tcsm.StoppageId,
 tcsm.RoleId,CASE WHEN r.RoleId=5 THEN 'Student' ELSE  r.Name END AS RoleName,
 tcsm.ConsumerId,tcsm.FromDate,tcsm.ToDate,
 tcsm.AcademicYearId,tcsm.PickDropId,tcsm.PickDropPrice,
 CASE WHEN tcsm.RoleId=3 THEN CONCAT(t.FirstName,' ',t.MiddleName,' ',t.LastName)
      WHEN tcsm.RoleId=2 THEN CONCAT(a.FirstName,' ',a.MiddleName,' ',a.LastName)
	  WHEN tcsm.RoleId=4 THEN CONCAT(c.FirstName,' ',c.MiddleName,' ',c.LastName)
	  WHEN tcsm.RoleId=6 THEN CONCAT(cb.FirstName,' ',cb.MiddleName,' ',cb.LastName)
	  WHEN tcsm.RoleId=5 THEN CONCAT(s.FirstName,' ',s.MiddleName,' ',s.LastName)
	  ELSE '' END AS UserName,CASE WHEN EXISTS (SELECT TOP (1) TransportFeePaymentId
										FROM dbo.TransportFeePayment 
										WHERE IsDeleted<>1 AND 
								TransportConsumerStoppageMappingId=tcsm.TransportConsumerStoppageMappingId)
								THEN 1 ELSE 0  END AS IsFeePaymentAlreadyDone
 FROM [dbo].TransportConsumerStoppageMapping tcsm JOIN
 [dbo].[Role] r ON tcsm.RoleId=r.RoleId LEFT JOIN 
 [dbo].[Teacher] t ON tcsm.ConsumerId=t.TeacherId AND tcsm.RoleId=3 LEFT JOIN
 [dbo].[Admin] a ON tcsm.ConsumerId=a.AdminId AND tcsm.RoleId=2 LEFT JOIN
 [dbo].Clerk c ON tcsm.ConsumerId=c.ClerkId AND tcsm.RoleId=4 LEFT JOIN
 [dbo].CabDriver cb ON tcsm.ConsumerId=cb.CabDriverId AND tcsm.RoleId=6 LEFT JOIN
 [dbo].Student s ON tcsm.ConsumerId=s.StudentId AND tcsm.RoleId=5 
 WHERE tcsm.AcademicYearId=@AcademicYearId 
 AND tcsm.StoppageId=@StoppageId AND tcsm.IsDeleted<>1
 AND ((@ConsumerName IS NULL OR @ConsumerName='') OR
  CASE WHEN tcsm.RoleId=3 THEN CONCAT(t.FirstName,' ',t.MiddleName,' ',t.LastName)
      WHEN tcsm.RoleId=2 THEN CONCAT(a.FirstName,' ',a.MiddleName,' ',a.LastName)
	  WHEN tcsm.RoleId=4 THEN CONCAT(c.FirstName,' ',c.MiddleName,' ',c.LastName)
	  WHEN tcsm.RoleId=6 THEN CONCAT(cb.FirstName,' ',cb.MiddleName,' ',cb.LastName)
	  WHEN tcsm.RoleId=5 THEN CONCAT(s.FirstName,' ',s.MiddleName,' ',s.LastName)
	  ELSE '' END LIKE '%'+@ConsumerName+'%' );

END TRY
BEGIN CATCH 
DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
@ErrorState 
END CATCH
END