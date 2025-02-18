CREATE PROCEDURE [dbo].[uspExistingTransportConsumerSelect](
@TransportConsumerStoppageMappingId INT,
@ConsumerId INT,
@RoleId INT,
@AcademicYearId SMALLINT
) AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY  


 SELECT tcsm.TransportConsumerStoppageMappingId,tcsm.StoppageId,
 tcsm.RoleId,CASE WHEN r.RoleId=5 THEN 'Student' ELSE  r.Name END AS RoleName,
 tcsm.ConsumerId,tcsm.FromDate,tcsm.ToDate,
 tcsm.AcademicYearId,tcsm.PickDropId,tcsm.PickDropPrice,st.StoppageName,
 CASE WHEN tcsm.RoleId=3 THEN CONCAT(t.FirstName,' ',t.MiddleName,' ',t.LastName)
      WHEN tcsm.RoleId=2 THEN CONCAT(a.FirstName,' ',a.MiddleName,' ',a.LastName)
	  WHEN tcsm.RoleId=4 THEN CONCAT(c.FirstName,' ',c.MiddleName,' ',c.LastName)
	  WHEN tcsm.RoleId=6 THEN CONCAT(cb.FirstName,' ',cb.MiddleName,' ',cb.LastName)
	  WHEN tcsm.RoleId=5 THEN CONCAT(s.FirstName,' ',s.MiddleName,' ',s.LastName)
	  ELSE '' END AS UserName
 FROM [dbo].TransportConsumerStoppageMapping tcsm JOIN
 [dbo].[Role] r ON tcsm.RoleId=r.RoleId JOIN
 [dbo].[TransportStoppage] st ON tcsm.StoppageId=st.StoppageId LEFT JOIN 
 [dbo].[Teacher] t ON tcsm.ConsumerId=t.TeacherId AND tcsm.RoleId=3 LEFT JOIN
 [dbo].[Admin] a ON tcsm.ConsumerId=a.AdminId AND tcsm.RoleId=2 LEFT JOIN
 [dbo].Clerk c ON tcsm.ConsumerId=c.ClerkId AND tcsm.RoleId=4 LEFT JOIN
 [dbo].CabDriver cb ON tcsm.ConsumerId=cb.CabDriverId AND tcsm.RoleId=6 LEFT JOIN
 [dbo].Student s ON tcsm.ConsumerId=s.StudentId AND tcsm.RoleId=5
 WHERE tcsm.AcademicYearId=@AcademicYearId 
 AND tcsm.RoleId=@RoleId AND tcsm.ConsumerId=@ConsumerId
 AND tcsm.TransportConsumerStoppageMappingId<>@TransportConsumerStoppageMappingId
 AND tcsm.IsDeleted<>1 AND st.IsDeleted<>1;

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