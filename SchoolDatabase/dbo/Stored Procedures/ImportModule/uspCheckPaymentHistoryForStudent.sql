--===============================================
-- Author:    Meena Kotkar
-- Create date: 02/04/2024
-- Description:  This stored procedure is used  for check paymentHistoy of Student 
-- =============================================
CREATE PROCEDURE [dbo].[uspCheckPaymentHistoryForStudent](
 @StudentImportType StudentImportType READONLY
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
 
  BEGIN TRY  
  Declare @UpdateFlag INT;
   
WITH cte AS (
    SELECT
        s.StudentId,
        st.Student_First_Name,
        st.Student_Middle_Name,
        st.Student_Last_Name,
		a.AcademicYearId,
        st.Grade AS Imported_Grade,
        st.Division AS Imported_Division
    FROM
        @StudentImportType st
		INNER JOIN Student s  ON st.Student_First_Name=s.FirstName AND st.Student_Middle_Name=s.MiddleName AND st.Student_Last_Name=s.LastName AND st.BirthDate=s.BirthDate
		INNER JOIN AcademicYear a ON  a.AcademicYearName=st.Academic_Year

    WHERE
        NOT EXISTS (
            SELECT 1
            FROM
                StudentGradeDivisionMapping sgdm
            INNER JOIN Grade g ON sgdm.GradeId = g.GradeId
            INNER JOIN Division d ON sgdm.DivisionId = d.DivisionId
            WHERE
                sgdm.StudentId = s.StudentId
                AND g.GradeName = st.Grade
                AND d.DivisionName = st.Division
			    AND sgdm.AcademicYearId=a.AcademicYearId
        )
)
SELECT
    cs.Student_First_Name,
    cs.Student_Middle_Name,
    cs.Student_Last_Name,
	dbo.udfStudentPaymentHistoryCheck(cs.AcademicYearId, cs.StudentId) AS HasPaymentHistory


FROM
    cte cs;

 

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