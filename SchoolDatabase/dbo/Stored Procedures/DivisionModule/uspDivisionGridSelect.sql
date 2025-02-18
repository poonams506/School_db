-- =============================================
-- Author:    Swapnil Bhaskar
-- Create date: 13/08/2023
-- Description:  This stored procedure is used to get Division info
-- =============================================
CREATE PROC uspDivisionGridSelect(@RequestModel NVARCHAR(MAX)) AS Begin
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
 
  SELECT COUNT(d.DivisionId)
  FROM Division d
  WHERE
    ISNULL(d.IsDeleted,0)<>1
  AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (d.DivisionName LIKE +@SearchText+'%'));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT d.DivisionId ,d.DivisionName
 FROM Division d
  WHERE
    ISNULL(d.IsDeleted,0)<>1
  AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (d.DivisionName LIKE +@SearchText+'%' ))
ORDER BY


--CASE  WHEN @OrderBy=0 THEN d.DivisionName END  DESC
CASE WHEN ISNUMERIC(d.DivisionName) = 1 THEN 0 ELSE 1 END,
                CASE WHEN ISNUMERIC(d.DivisionName) = 1 THEN CAST(d.DivisionName AS INT) ELSE 0 END DESC,
                d.DivisionName DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                                           
 END
 ELSE
 BEGIN
                           
         
 SELECT d.DivisionId ,d.DivisionName
 FROM Division d
  WHERE
    ISNULL(d.IsDeleted,0)<>1
  AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (d.DivisionName LIKE +@SearchText+'%' ))
ORDER BY


--CASE  WHEN @OrderBy=0 THEN d.DivisionName END  ASC
CASE WHEN ISNUMERIC(d.DivisionName) = 1 THEN 0 ELSE 1 END,
                CASE WHEN ISNUMERIC(d.DivisionName) = 1 THEN CAST(d.DivisionName AS INT) ELSE 0 END ASC,
                d.DivisionName ASC
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