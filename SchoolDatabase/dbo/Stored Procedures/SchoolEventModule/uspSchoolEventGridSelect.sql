-- =============================================
-- Author:   Prathamesh Ghule
-- Create date: 19/02/2024
-- Description:  This stored procedure is used to get school event grid data
-- =============================================
CREATE PROCEDURE uspSchoolEventGridSelect (@RequestModel NVARCHAR(MAX)) AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY
  DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
 DECLARE @GradeId SMALLINT = JSON_VALUE(@RequestModel, '$.gradeId');
 DECLARE @DivisionId SMALLINT = JSON_VALUE(@RequestModel, '$.divisionId');
 DECLARE @PageSize INT=JSON_VALUE(@RequestModel, '$.getListModel.length');
 DECLARE @PageNumber INT=JSON_VALUE(@RequestModel, '$.getListModel.start');
 DECLARE @SearchText NVARCHAR(150)=JSON_VALUE(@RequestModel, '$.getListModel.search.value');
 DECLARE @OrderBy INT=JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
 DECLARE @OrderBy_ASC_DESC NVARCHAR(20)=JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');
 DECLARE @SearchDate DATE;
        IF ISDATE(@SearchText) = 1
        BEGIN
            SET @SearchDate = CONVERT(DATE, @SearchText, 103);
        END
 
  SELECT COUNT(se.SchoolEventId)
  FROM SchoolEvent se
  WHERE
   
   ISNULL(se.IsDeleted,0)<>1 
   AND se.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0
  OR  LEN(@SearchText)>0 AND (se.EventTitle LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventDescription LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventFess LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventVenue LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventCoordinator LIKE '%'+@SearchText+'%')
  OR CONVERT(NVARCHAR(10), se.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
  OR CONVERT(NVARCHAR(10), se.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
  OR se.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
  OR se.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
  OR  LEN(@SearchText)>0 AND (IIF( se.IsCompulsory = 1,'Compulsory','Not Compulsory') LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (IIF( se.IsPublished = 1,'Published','Unpublished') LIKE '%'+@SearchText+'%')

  );

  IF(@OrderBy_Asc_DESC='desc')
 BEGIN
                          
 SELECT 
 se.SchoolEventID,
 se.AcademicYearId,
se.EventTitle,
se.EventDescription,
se.EventFess,
se.EventVenue,
se.EventCoordinator,
se.StartDate,
se.EndDate,
CASE WHEN se.IsCompulsory = 1 THEN 'Compulsory'
          WHEN se.IsCompulsory = 0 THEN 'Not Compulsory'
          END AS 'Remark',
CASE WHEN se.IsPublished = 1 THEN 'Published'
          WHEN se.IsPublished = 0 THEN 'Unpublished'
          END AS 'Status'

  FROM SchoolEvent se

  WHERE
   ISNULL(se.IsDeleted,0)<>1 
   AND se.AcademicYearId = @AcademicYearId
  AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND (se.EventTitle LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventDescription LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventFess LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventVenue LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventCoordinator LIKE '%'+@SearchText+'%')
  OR CONVERT(NVARCHAR(10), se.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
  OR CONVERT(NVARCHAR(10), se.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
  OR se.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
  OR se.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
  OR  LEN(@SearchText)>0 AND (IIF( se.IsCompulsory = 1,'Compulsory','Not Compulsory') LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (IIF( se.IsPublished = 1,'Published','Unpublished') LIKE '%'+@SearchText+'%')
  )
ORDER BY
  CASE  WHEN @OrderBy=0 THEN se.EventTitle END DESC,
  CASE  WHEN @OrderBy=1 THEN se.EventFess END DESC,
  CASE  WHEN @OrderBy=2 THEN se.EventVenue END DESC,
  CASE  WHEN @OrderBy=3 THEN se.EventCoordinator END DESC,
  CASE  WHEN @OrderBy=4 THEN se.StartDate END DESC,
  CASE  WHEN @OrderBy=5 THEN se.EndDate END DESC,
  CASE  WHEN @OrderBy=6 THEN se.IsPublished END DESC

OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                  
                              
                                
 END
 ELSE
 BEGIN
 
 SELECT 
  se.SchoolEventID,
 se.AcademicYearId,
se.EventTitle,
se.EventDescription,
se.EventFess,
se.EventVenue,
se.EventCoordinator,
se.StartDate,
se.EndDate,

CASE WHEN se.IsCompulsory = 1 THEN 'Compulsory'
          WHEN se.IsCompulsory = 0 THEN 'Not Compulsory'
          END AS 'Remark',
CASE WHEN se.IsPublished = 1 THEN 'Published'
          WHEN se.IsPublished = 0 THEN 'Unpublished'
          END AS 'Status'
  FROM SchoolEvent se

  WHERE
   ISNULL(se.IsDeleted,0)<>1 
  AND se.AcademicYearId = @AcademicYearId
  AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND (se.EventTitle LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventDescription LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventFess LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventVenue LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (se.EventCoordinator LIKE '%'+@SearchText+'%')
  OR CONVERT(NVARCHAR(10), se.StartDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
  OR CONVERT(NVARCHAR(10), se.EndDate, 103) LIKE '%' + ISNULL(@SearchText, '') + '%' AND ISDATE(@SearchText) = 0
  OR se.StartDate = @SearchDate AND ISDATE(@SearchText) = 1
  OR se.EndDate = @SearchDate AND ISDATE(@SearchText) = 1
  OR  LEN(@SearchText)>0 AND (IIF( se.IsCompulsory = 1,'Compulsory','Not Compulsory') LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (IIF( se.IsPublished = 1,'Published','Unpublished') LIKE '%'+@SearchText+'%')
  )
ORDER BY
  CASE  WHEN @OrderBy=0 THEN se.EventTitle END ASC,
  CASE  WHEN @OrderBy=1 THEN se.EventFess END ASC,
  CASE  WHEN @OrderBy=2 THEN se.EventVenue END ASC,
  CASE  WHEN @OrderBy=3 THEN se.EventCoordinator END ASC,
  CASE  WHEN @OrderBy=4 THEN se.StartDate END ASC,
  CASE  WHEN @OrderBy=5 THEN se.EndDate END ASC,
  CASE  WHEN @OrderBy=6 THEN se.IsPublished END ASC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
         
END 
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
