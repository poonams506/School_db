-- =============================================
-- Author:   Deepak Walunj
-- Create date: 15/08/2023
-- Description:  This stored procedure is used to get Admin info in Grid
-- =============================================
CREATE PROC uspAdminGridSelect(@RequestModel NVARCHAR(MAX)) AS Begin
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
 
  SELECT COUNT(A.AdminId)
  FROM [Admin] A
  WHERE
    ISNULL(A.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (A.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (A.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.EmailId LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (A.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.DistrictName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.AppAccessMobileNo LIKE '%'+@SearchText+'%')
  ));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT 
  A.AdminId,
  A.FirstName + ' ' + A.MiddleName + ' ' + A.LastName as 'FullName'
  , A.MobileNumber
 , ISNULL(A.AddressLine1,'') + IIF(A.AddressLine1 IS NULL,'',', ') + ISNULL(A.AddressLine2,'') + IIF(A.AddressLine2 IS NULL,'',', ') + A.TalukaName + ', ' + A.DistrictName + IIF(A.ZipCode IS NULL,'',', ' + A.ZipCode) AS 'Address'
 , A.EmailId
 , A.AppAccessMobileNo
  FROM [Admin] A
  WHERE
     ISNULL(A.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (A.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (A.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.EmailId LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (A.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.DistrictName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.AppAccessMobileNo LIKE '%'+@SearchText+'%')
  ))
ORDER BY
  CASE  WHEN @OrderBy=0 THEN A.FirstName + ' ' + A.MiddleName + ' ' + A.LastName END DESC,
  CASE  WHEN @OrderBy=1 THEN A.MobileNumber END DESC,
  CASE  WHEN @OrderBy=2 THEN ISNULL(A.AddressLine1,'') + IIF(A.AddressLine1 IS NULL,'',', ') + ISNULL(A.AddressLine2,'') + IIF(A.AddressLine2 IS NULL,'',', ') + A.TalukaName + ', ' + A.DistrictName + IIF(A.ZipCode IS NULL,'',', ' + A.ZipCode) END DESC,
  CASE  WHEN @OrderBy=3 THEN A.EmailId END DESC,
  CASE  WHEN @OrderBy=4 THEN A.AppAccessMobileNo END DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                  
                              
                                
 END
 ELSE
 BEGIN
 
  SELECT 
  A.AdminId,
  A.FirstName + ' ' + A.MiddleName + ' ' + A.LastName as 'FullName'
  , A.MobileNumber
 , ISNULL(A.AddressLine1,'') + IIF(A.AddressLine1 IS NULL,'',', ') + ISNULL(A.AddressLine2,'') + IIF(A.AddressLine2 IS NULL,'',', ') + A.TalukaName + ', ' + A.DistrictName + IIF(A.ZipCode IS NULL,'',', ' + A.ZipCode) AS 'Address'
  ,A.EmailId
  , A.AppAccessMobileNo
  FROM [Admin] A
  WHERE
     ISNULL(A.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (A.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (A.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.EmailId LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (A.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.DistrictName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (A.AppAccessMobileNo LIKE '%'+@SearchText+'%')
  ))
ORDER BY
  CASE  WHEN @OrderBy=0 THEN A.FirstName + ' ' + A.MiddleName + ' ' + A.LastName END ASC,
  CASE  WHEN @OrderBy=1 THEN A.MobileNumber END ASC,
  CASE  WHEN @OrderBy=2 THEN ISNULL(A.AddressLine1,'') + IIF(A.AddressLine1 IS NULL,'',', ') + ISNULL(A.AddressLine2,'') + IIF(A.AddressLine2 IS NULL,'',', ') + A.TalukaName + ', ' + A.DistrictName + IIF(A.ZipCode IS NULL,'',', ' + A.ZipCode) END ASC,  
  CASE  WHEN @OrderBy=3 THEN A.EmailId END ASC,
  CASE  WHEN @OrderBy=4 THEN A.AppAccessMobileNo END ASC
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