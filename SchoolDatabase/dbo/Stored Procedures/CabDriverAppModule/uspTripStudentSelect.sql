
-- Author:    praythamesh ghule
-- Create date: 18/06/2024
-- Description:  This stored procedure is used to get student  
-- =============================================
CREATE PROCEDURE [dbo].[uspTripStudentSelect]
	 (@TripId BIGINT)AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

 SELECT 
        t.TripId,
        td.StudentId,
	     CONCAT (s.FirstName, ' ', s.MiddleName, ' ', s.LastName) As 'StudentName'
      
      
    FROM 
        TripDetail td
		INNER JOIN Trip t on t.TripId =td.TripId
		INNER JOIN Student s on td.StudentId=s.StudentId

    WHERE 
        t.TripId = @TripId AND CAST( PickUpDateTime AS DATE) = CAST(GETDATE() AS DATE)

  
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