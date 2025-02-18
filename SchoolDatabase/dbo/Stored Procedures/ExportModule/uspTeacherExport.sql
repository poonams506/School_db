-- =============================================
-- Author:    Meena Kotkar
-- Create date: 26/02/2024
-- Description:  This stored procedure is used to export Teacher info detail 
-- =============================================
CREATE PROC [dbo].[uspTeacherExport] AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY
        SELECT 
           
            t.FirstName,
            t.MiddleName, 
            t.LastName, 
            t.Gender, 
			t.MobileNumber,
			t.ContactNumber,
			t.EmailId,
			t.AddressLine1,
			t.AddressLine2,
			 t.CountryName,
			 t.StateName, 
             t.DistrictName,
			 t.TalukaName,         
			 t.ZipCode AS Pincode,
			 t.AdharNumber,
			 t.Education,
			REPLACE(CONVERT(NVARCHAR(20), t.BirthDate, 105), '-', '_') AS BirthDate ,
        	t.BloodGroup,
            CASE  WHEN t.IsAppAccess=1 THEN 'Y'
			WHEN t.IsAppAccess=0 THEN 'N'END AS 'IsAppAccess',
            t.AppAccessMobileNo
			
           FROM 
            Teacher t
            WHERE  
            t.IsDeleted <> 1 ;
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
