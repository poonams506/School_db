-- =============================================  
-- Author:    Deepak W  
-- Create date: 19/08/2023  
-- Description:  get homework list for teacher app  
-- =============================================  
CREATE PROC uspTeacherHomeworkSelect(@AcademicYearId INT,@Month INT, @Year INT, @UserId INT)  
AS Begin   
SET   
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
SET   
  NOCOUNT ON;  
BEGIN TRY   
  
          SELECT   
                h.HomeWorkId,  
                g.GradeName,  
                d.DivisionName,  
                h.EndDate,  
                h.IsPublished,  
                h.StartDate,  
                h.Title AS HomeworkTitle,  
                s.SubjectName,  
                CASE   
                    WHEN h.IsPublished = 1 THEN 'Published'  
                    WHEN h.IsPublished = 0 THEN 'Unpublished'  
                    END AS 'Status',  
                    CONCAT(g.GradeName, ' - ', d.DivisionName) AS 'Class',  
                    CONCAT(u.Fname , ' ',u.Mname, ' ' ,u.Lname) AS 'CreatedBy',  
                    h.CreatedDate,  
                    CASE   
                       WHEN h.ModifiedDate IS NULL THEN ''  
        ELSE ISNULL(CONCAT(u_modified.Fname , ' ',u_modified.Mname, ' ' ,u_modified.Lname), '')  
        END AS 'ModifiedBy',  
                    h.ModifiedDate  
            FROM dbo.HomeWork AS h  
            INNER JOIN dbo.Grade g ON h.GradeId = g.GradeId  
            INNER JOIN dbo.Division d ON h.DivisionId = d.DivisionId  
            INNER JOIN dbo.[SubjectMaster] s ON h.SubjectId = s.SubjectMasterId  
   LEFT JOIN dbo.[User] u ON u.UserId  = @UserId
   LEFT JOIN dbo.[User] u_modified ON u_modified.UserId    =@UserId
            WHERE  
                ISNULL(d.IsDeleted, 0) <> 1  
                AND ISNULL(h.IsDeleted, 0) <> 1  
                AND ISNULL(g.IsDeleted, 0) <> 1  
                AND ISNULL(s.IsDeleted, 0) <> 1  
                AND h.AcademicYearId = @AcademicYearId  
                AND h.CreatedBy = @UserId  
                AND MONTH(h.StartDate) = @Month AND YEAR(h.StartDate) = @Year  
           ORDER BY  h.HomeWorkId DESC  
  
 END   
  
 TRY   
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