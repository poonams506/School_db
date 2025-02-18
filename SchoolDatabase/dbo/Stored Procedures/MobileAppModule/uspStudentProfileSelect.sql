-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 17/02/2024
-- Description:  This stored procedure is used to get Student Detail for Mobile App.
-- =============================================
CREATE PROCEDURE uspStudentProfileSelect(@StudentId INT)
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

    SELECT s.StudentId, s.FirstName,s.MiddleName,s.LastName,
          CONCAT(s.FirstName,' ',s.MiddleName,' ',s.LastName) AS StudentFullName,
           s.CurrentAddressLine1,s.CurrentAddressLine2,
           s.CurrentCountryId,s.CurrentStateId,
           s.CurrentDistrictId,s.CurrentTalukaId,
           s.CurrentZipcode,s.ProfileImageUrl
    FROM dbo.[Student] s
    WHERE s.StudentId=@StudentId AND s.IsArchive <> 1
    AND s.IsDeleted<>1;

 END 
 TRY 
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

