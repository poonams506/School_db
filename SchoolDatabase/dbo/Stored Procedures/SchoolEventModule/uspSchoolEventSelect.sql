-- =============================================
-- Author:   Prathamesh Ghule
-- Create date: 16/02/2024
-- Description:  This stored procedure is used to get school event  data
-- =============================================
CREATE PROCEDURE uspSchoolEventSelect (@SchoolEventId INT)AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

Declare @AcademicYearId INT;
SELECT 
 @AcademicYearId = se.AcademicYearId
  FROM SchoolEvent se
WHERE 
  SchoolEventId = ISNULL(@SchoolEventId, SchoolEventId) AND se.IsDeleted <>1

 SELECT 
 se.SchoolEventId,
 se.AcademicYearId,
se.EventTitle,
se.EventDescription,
se.EventFess,
se.EventVenue,
se.EventCoordinator,
se.StartDate,
se.EndDate,
se.StartTime,
se.EndTime,
se.IsCompulsory,
se.IsPublished

  FROM SchoolEvent se

WHERE 
  SchoolEventId = ISNULL(@SchoolEventId, SchoolEventId) AND se.IsDeleted <>1  

   SELECT 
            sed.SchoolEventId,
            sed.FileName,
            sed.FileType
        FROM
            dbo.SchoolEventDetails AS sed
        WHERE
             sed.SchoolEventId = @SchoolEventId AND
            sed.IsDeleted <> 1 



             SELECT sem.SchoolEventId ,sgdm.SchoolGradeDivisionMatrixId AS ClassId
     FROM dbo.SchoolEventMapping sem
    LEFT JOIN 
      dbo.SchoolGradeDivisionMatrix sgdm ON  sem.GradeId=sgdm.GradeId AND sem.DivisionId=sgdm.DivisionId AND sgdm.AcademicYearId = @AcademicYearId
    WHERE sem.SchoolEventId=@SchoolEventId AND  sgdm.IsDeleted <> 1 ;
           
          

  
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
