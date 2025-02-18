-- =============================================
-- Author:    Meena Kotkar
-- Create date: 09/04/2024
-- Description:  This stored procedure is used to get Area info in Grid
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportAreaGridSelect](@RequestModel NVARCHAR(MAX)) AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY
 DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
 DECLARE @PageSize INT=JSON_VALUE(@RequestModel, '$.getListModel.length');
 DECLARE @PageNumber INT=JSON_VALUE(@RequestModel, '$.getListModel.start');
 DECLARE @SearchText NVARCHAR(150)=JSON_VALUE(@RequestModel, '$.getListModel.search.value');
 DECLARE @OrderBy INT=JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
 DECLARE @OrderBy_ASC_DESC NVARCHAR(20)=JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');
 
  SELECT COUNT(A.AreaId)
   FROM TransportArea A
  WHERE
  A.AcademicYearId=@AcademicYearId AND 
    ISNULL(A.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (A.AreaName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (A.PickPrice LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.DropPrice LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.PickAndDropPrice LIKE '%'+@SearchText+'%')
   ));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT 
  A.AreaId,
  A.AreaName,
  A.PickPrice,
  A.DropPrice,
  A.PickAndDropPrice,
  A.Description
   FROM TransportArea A
  WHERE
  A.AcademicYearId=@AcademicYearId AND 
     ISNULL(A.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (A.AreaName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (A.PickPrice LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.DropPrice LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.PickAndDropPrice LIKE '%'+@SearchText+'%')
   ))
ORDER BY
  CASE  WHEN @OrderBy=0 THEN A.AreaName END DESC,
   CASE  WHEN @OrderBy=1 THEN  A.PickPrice END DESC,
  CASE  WHEN @OrderBy=2 THEN  A.DropPrice END DESC,
  CASE  WHEN @OrderBy=3 THEN  A.PickAndDropPrice END DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                  
                              
                                
 END
 ELSE
 BEGIN
 
  SELECT 
   A.AreaId,
  A.AreaName,
  A.PickPrice,
  A.DropPrice,
  A.PickAndDropPrice,
  A.Description,
  A.AcademicYearId
  FROM TransportArea A
  WHERE
  A.AcademicYearId=@AcademicYearId AND 
     ISNULL(A.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (A.AreaName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (A.PickPrice LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.DropPrice LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.PickAndDropPrice LIKE '%'+@SearchText+'%')
   ))
ORDER BY
   CASE  WHEN @OrderBy=0 THEN A.AreaName END ASC,
   CASE  WHEN @OrderBy=1 THEN  A.PickPrice END ASC,
  CASE  WHEN @OrderBy=2 THEN  A.DropPrice END ASC,
  CASE  WHEN @OrderBy=3 THEN  A.PickAndDropPrice END ASC
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