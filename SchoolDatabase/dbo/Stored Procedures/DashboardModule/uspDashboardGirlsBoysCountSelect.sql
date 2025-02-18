-- =============================================
-- Author:    Shambala Apugade
-- Create date: 11/03/2024
-- Description:  This stored procedure is used to get Student dashboard detail
-- =============================================
CREATE PROC uspDashboardGirlsBoysCountSelect AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 


SELECT
COUNT(s.StudentId) AS TotalCount,
COUNT(CASE WHEN Gender = 'M' then 1 End) AS BoysCount,
COUNT(CASE WHEN Gender = 'F' then 1 End)AS GirlsCount
FROM Student s --INNER JOIN
--StudentGradeDivisionMapping M
--ON m.StudentId = s.StudentId 
WHERE s.IsDeleted <> 1 and s.IsArchive <> 1


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
