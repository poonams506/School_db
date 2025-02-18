-- =============================================
-- Author:    Meena Kotkar
-- Create date: 12/03/2024
-- Description:  This stored procedure is check student is exist or not
-- =============================================
CREATE PROCEDURE [dbo].[uspCheckStudentExist]
(
  @FirstName NVARCHAR(50), 
  @MiddleName NVARCHAR(50), 
  @LastName NVARCHAR(50), 
  @BirthDate DATE ,
  @StudentId BIGINT,
  @AcademicYearId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

   BEGIN TRY 
		
	SELECT CASE WHEN COUNT(s.StudentId)>0 AND ISNULL(@StudentId,0)=0 THEN 1 ELSE 0 END AS Exist
	FROM dbo.Student S
	WHERE CONCAT(FirstName,MiddleName,LastName) = CONCAT(@FirstName,@MiddleName,@LastName) AND BirthDate=@BirthDate And s.IsDeleted<>1 And s.IsArchive <> 1
 
  END TRY

BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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