-- =============================================
-- Author:   Swapnil Bhaskar
-- Create date: 15/08/2023
-- Description:  This stored procedure is used to get Clerk info in Grid
-- =============================================
CREATE PROC uspClerkGridSelect(@RequestModel NVARCHAR(MAX)) AS Begin
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
 
  SELECT COUNT(C.ClerkId)
  FROM Clerk C
 
  WHERE
    ISNULL(C.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (C.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (C.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.EmailId LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.DistrictName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.AppAccessMobileNo LIKE '%'+@SearchText+'%')
  ));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT 
  C.ClerkId,
  C.FirstName + ' ' + C.MiddleName + ' ' + C.LastName as 'FullName'
  , C.MobileNumber
 , ISNULL(C.AddressLine1,'') + IIF(C.AddressLine1 IS NULL,'',', ') + ISNULL(C.AddressLine2,'') + IIF(C.AddressLine2 IS NULL,'',', ') + C.TalukaName + ', ' + C.DistrictName + IIF(C.ZipCode IS NULL,'',', ' + C.ZipCode) AS 'Address'
  ,C.EmailId
  ,C.AppAccessMobileNo
  FROM Clerk C
  WHERE
     ISNULL(C.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (C.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (C.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.EmailId LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (C.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.DistrictName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.AppAccessMobileNo LIKE '%'+@SearchText+'%')
  ))
ORDER BY
  CASE  WHEN @OrderBy=0 THEN C.FirstName + ' ' + C.MiddleName + ' ' + C.LastName END DESC,
  CASE  WHEN @OrderBy=1 THEN C.MobileNumber END DESC,
  CASE  WHEN @OrderBy=2 THEN ISNULL(C.AddressLine1,'') + IIF(C.AddressLine1 IS NULL,'',', ') + ISNULL(C.AddressLine2,'') + IIF(C.AddressLine2 IS NULL,'',', ') + C.TalukaName + ', ' + C.DistrictName + IIF(C.ZipCode IS NULL,'',', ' + C.ZipCode) END DESC,
  CASE  WHEN @OrderBy=3 THEN C.EmailId END DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                  
                              
                                
 END
 ELSE
 BEGIN
 
  SELECT 
  C.ClerkId,
  C.FirstName + ' ' + C.MiddleName + ' ' + C.LastName as 'FullName'
  , C.MobileNumber
  , ISNULL(C.AddressLine1,'') + IIF(C.AddressLine1 IS NULL,'',', ') + ISNULL(C.AddressLine2,'') + IIF(C.AddressLine2 IS NULL,'',', ') + C.TalukaName + ', ' + C.DistrictName + IIF(C.ZipCode IS NULL,'',', ' + C.ZipCode) AS 'Address'
  ,C.EmailId
  ,C.AppAccessMobileNo
  FROM Clerk C
  WHERE
     ISNULL(C.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (C.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (C.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.EmailId LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (C.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.DistrictName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (C.AppAccessMobileNo LIKE '%'+@SearchText+'%')
  ))
ORDER BY
  CASE  WHEN @OrderBy=0 THEN C.FirstName + ' ' + C.MiddleName + ' ' + C.LastName END ASC,
  CASE  WHEN @OrderBy=1 THEN C.MobileNumber END ASC,
  CASE  WHEN @OrderBy=2 THEN ISNULL(C.AddressLine1,'') + IIF(C.AddressLine1 IS NULL,'',', ') + ISNULL(C.AddressLine2,'') + IIF(C.AddressLine2 IS NULL,'',', ') + C.TalukaName + ', ' + C.DistrictName + IIF(C.ZipCode IS NULL,'',', ' + C.ZipCode) END ASC,  
  CASE  WHEN @OrderBy=3 THEN C.EmailId END ASC,
  CASE  WHEN @OrderBy=4 THEN C.AppAccessMobileNo END ASC
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