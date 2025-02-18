-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 01/03/2024
-- Description:  This stored procedure is used to get Subject Master info
-- =============================================
CREATE PROC uspSubjectMasterGridSelect(@RequestModel NVARCHAR(MAX)) AS BEGIN
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY
 DECLARE @PageSize INT=JSON_VALUE(@RequestModel, '$.getListModel.length');
 DECLARE @PageNumber INT=JSON_VALUE(@RequestModel, '$.getListModel.start');
 DECLARE @SearchText NVARCHAR(150)=JSON_VALUE(@RequestModel, '$.getListModel.search.value');
 DECLARE @OrderBy INT=JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
 DECLARE @OrderBy_ASC_DESC NVARCHAR(20)=JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');
 
  SELECT COUNT(sm.SubjectMasterId)
  FROM dbo.SubjectMaster sm
  WHERE
    ISNULL(sm.IsDeleted,0)<>1
  AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (sm.SubjectName LIKE +@SearchText+'%'));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT
 sm.SubjectMasterId,
 sm.SubjectName
 FROM dbo.SubjectMaster sm
  WHERE
    ISNULL(sm.IsDeleted,0)<>1
  AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (sm.SubjectName LIKE +@SearchText+'%' ))
ORDER BY
CASE  WHEN @OrderBy=0 THEN sm.SubjectName END  DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                  
 END
 ELSE
 BEGIN
         
 SELECT
 sm.SubjectMasterId,
 sm.SubjectName
 FROM dbo.SubjectMaster sm
  WHERE
     ISNULL(sm.IsDeleted,0)<>1
  AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (sm.SubjectName LIKE +@SearchText+'%'))
ORDER BY
CASE  WHEN @OrderBy=0 THEN sm.SubjectName END  ASC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
END

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
@ErrorState END CATCH End