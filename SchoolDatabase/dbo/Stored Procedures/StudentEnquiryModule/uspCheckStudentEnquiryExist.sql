-- =============================================
-- Author:    Prerana Aher
-- Create date: 12/08/2024
-- Description:  This stored procedure is check student enquiry is exist or not
-- =============================================
CREATE PROCEDURE [dbo].[uspCheckStudentEnquiryExist](
  @StudentFirstName NVARCHAR(50),
  @StudentMiddleName NVARCHAR(50),
  @StudentLastName NVARCHAR(50),
  @BirthDate DATE ,
  @StudentEnquiryId INT
) 
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

   BEGIN TRY 
		
	SELECT CASE WHEN COUNT(s.StudentEnquiryId)>0 AND ISNULL(@StudentEnquiryId,0)=0 THEN 1 ELSE 0 END AS Exist
	FROM dbo.StudentEnquiry s
	WHERE CONCAT(StudentFirstName,StudentMiddleName,StudentLastName) = CONCAT(@StudentFirstName,@StudentMiddleName,@StudentLastName) AND BirthDate=@BirthDate And s.IsDeleted<>1
 
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