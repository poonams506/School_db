-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 18/04/2024
-- Description:  This stored procedure is used to get parent details by student id for mobile app.
-- =============================================
CREATE PROC dbo.uspMobileAppParentSelect(@StudentId BIGINT) 
AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 


--Select Father
SELECT stu.StudentId,p.ParentId,p.ParentTypeId,
       p.FirstName,p.MiddleName,p.LastName,
	   p.AddressLine1,p.AddressLine2,p.CountryId,
	   p.StateId,p.DistrictId,p.TalukaId,p.ProfileImageURL,
	   CONCAT(p.FirstName,' ',p.MiddleName,' ',p.LastName) AS FullName,
	   p.Zipcode
FROM dbo.Student stu JOIN
dbo.ParentStudentMapping psm ON stu.StudentId=psm.StudentId JOIN
dbo.Parent p ON psm.ParentId=p.ParentId 
WHERE psm.StudentId=@StudentId AND p.IsDeleted<>1 AND stu.IsArchive <> 1
      AND p.ParentTypeId=11;

--Select Mother
SELECT stu.StudentId,p.ParentId,p.ParentTypeId,
       p.FirstName,p.MiddleName,p.LastName,
	   p.AddressLine1,p.AddressLine2,p.CountryId,
	   p.StateId,p.DistrictId,p.TalukaId,p.ProfileImageURL,
	    CONCAT(p.FirstName,' ',p.MiddleName,' ',p.LastName) AS FullName,
		p.Zipcode
FROM dbo.Student stu JOIN
dbo.ParentStudentMapping psm ON stu.StudentId=psm.StudentId JOIN
dbo.Parent p ON psm.ParentId=p.ParentId 
WHERE psm.StudentId=@StudentId AND p.IsDeleted<>1 AND stu.IsArchive <> 1
      AND p.ParentTypeId=12;

--Select Guardian
SELECT stu.StudentId,p.ParentId,p.ParentTypeId,
       p.FirstName,p.MiddleName,p.LastName,
	   p.AddressLine1,p.AddressLine2,p.CountryId,
	   p.StateId,p.DistrictId,p.TalukaId,p.ProfileImageURL,
	    CONCAT(p.FirstName,' ',p.MiddleName,' ',p.LastName) AS FullName,
		p.Zipcode
FROM dbo.Student stu JOIN
dbo.ParentStudentMapping psm ON stu.StudentId=psm.StudentId JOIN
dbo.Parent p ON psm.ParentId=p.ParentId 
WHERE psm.StudentId=@StudentId AND p.IsDeleted<>1 AND stu.IsArchive <> 1
      AND p.ParentTypeId=13;

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
GO
