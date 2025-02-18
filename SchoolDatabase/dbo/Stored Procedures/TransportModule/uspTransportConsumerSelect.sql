-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 07/05/2024
-- Description:  This stored procedure is used to get all consumer
-- =============================================
CREATE PROC dbo.uspTransportConsumerSelect(
@AcademicYearId SMALLINT,@RoleId INT,@StoppageId INT)
AS
BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 

NOCOUNT ON;
BEGIN TRY 

     DECLARE @IsFeeApplicableToStaff BIT;
     SET @IsFeeApplicableToStaff = (SELECT IsFeeApplicableToStaff FROM SchoolSetting WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1)
     IF(@RoleId=3)
     BEGIN
        --Select Teacher
        SELECT 3 AS RoleId,TeacherId AS UserId,CONCAT(FirstName,' ',LastName) AS UserName, @IsFeeApplicableToStaff AS IsFeeApplicableToStaff
        FROM dbo.Teacher WHERE IsDeleted<>1
        ORDER BY CONCAT(FirstName,' ',LastName) ASC;
     END
     ELSE IF(@RoleId=2)
     BEGIN
        --Select Admin
        SELECT 2 AS RoleId,AdminId AS UserId,CONCAT(FirstName,' ',LastName) AS UserName, @IsFeeApplicableToStaff AS IsFeeApplicableToStaff
        FROM dbo.[Admin] WHERE IsDeleted<>1
        ORDER BY CONCAT(FirstName,' ',LastName) ASC;
     END
     ELSE IF(@RoleId=4)
     BEGIN
        --Select Clerk
        SELECT 4 AS RoleId,ClerkId AS UserId,CONCAT(FirstName,' ',LastName) AS UserName, @IsFeeApplicableToStaff AS IsFeeApplicableToStaff
        FROM dbo.[Clerk] WHERE IsDeleted<>1
        ORDER BY CONCAT(FirstName,' ',LastName) ASC;
     END
     ELSE IF(@RoleId=6)
     BEGIN
         --Select CAB Driver
         SELECT 6 AS RoleId,CabDriverId AS UserId,CONCAT(FirstName,' ',LastName) AS UserName, @IsFeeApplicableToStaff AS IsFeeApplicableToStaff
         FROM dbo.[CabDriver] WHERE IsDeleted<>1
         ORDER BY CONCAT(FirstName,' ',LastName) ASC;
     END
     ELSE IF(@RoleId=5)
     BEGIN
         --Select Student
        SELECT 5 AS RoleId,s.StudentId AS UserId,CONCAT(s.FirstName,' ',s.LastName) AS UserName, @IsFeeApplicableToStaff AS IsFeeApplicableToStaff,
	    sgdm.SchoolGradeDivisionMatrixId AS ClassId,
	    CONCAT(g.GradeName,'-',d.DivisionName) AS ClassName
        FROM dbo.[Student] s  JOIN
        dbo.StudentGradeDivisionMapping sgm ON s.StudentId=sgm.StudentId JOIN
        dbo.Grade g ON sgm.GradeId=g.GradeId JOIN
        dbo.Division d ON  d.DivisionId=sgm.DivisionId JOIN
        dbo.SchoolGradeDivisionMatrix sgdm ON sgm.GradeId=sgdm.GradeId AND sgm.DivisionId=sgdm.DivisionId
	    WHERE s.IsDeleted<>1 AND sgm.AcademicYearId=@AcademicYearId AND sgdm.AcademicYearId=@AcademicYearId
        AND sgm.IsDeleted<>1 AND sgdm.IsDeleted<>1 AND ISNULL(s.IsArchive, 0) = 0 
        ORDER BY len(g.GradeName + ' - ' + d.DivisionName) ASC, g.GradeName + ' - ' + d.DivisionName ASC, CONCAT(s.FirstName,' ',s.LastName) ASC
        ;

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
GO
