--===============================================
-- Author:    Meena Kotkar
-- Create date: 02/04/2024
-- Description:  This stored procedure is used  for check genRegNo of Student 
-- =============================================
CREATE PROCEDURE [dbo].[uspCheckGeneralRegNoExist](
 @StudentImportType StudentImportType READONLY
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
 
  BEGIN TRY  
  
   
WITH cte AS (
    SELECT
		st.Gen_Reg_No,
        st.Student_First_Name,
        st.Student_Middle_Name,
        st.Student_Last_Name,
		st.BirthDate
    FROM
        @StudentImportType st
)
SELECT
    cs.Student_First_Name,
    cs.Student_Middle_Name,
    cs.Student_Last_Name,
	 ISNULL(s.StudentId, 0) AS StudentId,
	dbo.udfStudentGenRegNoCheck(cs.Gen_Reg_No,ISNULL(s.StudentId, 0)) As 'GenRegNoExist'
FROM
    cte cs
	LEFT JOIN Student s  ON cs.Student_First_Name=s.FirstName AND cs.Student_Middle_Name=s.MiddleName AND cs.Student_Last_Name=s.LastName AND cs.BirthDate=s.BirthDate
	WHERE s.IsDeleted<>1 OR   s.StudentId IS NULL; ;

 

  END TRY
    BEGIN CATCH
      -- Log the exception
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
                                 @ErrorState;
    END CATCH
  END