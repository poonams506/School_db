-- =============================================
-- Author:   Swapnil Bhaskar
-- Create date: 15/08/2023
-- Description:  This stored procedure is used to get CabDriver info in Grid
-- =============================================
CREATE PROC uspCabDriverGridSelect(@RequestModel NVARCHAR(MAX)) AS Begin
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
 
  SELECT COUNT(CD.CabDriverId)
  FROM CabDriver CD
 
  WHERE
    ISNULL(CD.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (CD.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (CD.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.EmailId LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.DrivingLicenceNumber LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (CD.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.DistrictName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.AppAccessMobileNo LIKE '%'+@SearchText+'%')

  
  ));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT 
  CD.CabDriverId,
  CD.FirstName + ' ' + CD.MiddleName + ' ' + CD.LastName as 'FullName'
  , CD.MobileNumber
   , ISNULL(CD.AddressLine1,'') + IIF(CD.AddressLine1 IS NULL,'',', ') + ISNULL(CD.AddressLine2,'') + IIF(CD.AddressLine2 IS NULL,'',', ') + CD.TalukaName + ', ' + CD.DistrictName + IIF(CD.ZipCode IS NULL,'',', ' + CD.ZipCode) AS 'Address'
    ,CD.EmailId, CD.DrivingLicenceNumber, CD.ValidTill,CD.AppAccessMobileNo
  FROM CabDriver CD
  WHERE
     ISNULL(CD.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (CD.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (CD.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.EmailId LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.DrivingLicenceNumber LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (CD.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.DistrictName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (CD.AppAccessMobileNo LIKE '%'+@SearchText+'%')

  
  ))
ORDER BY
  CASE  WHEN @OrderBy=0 THEN CD.FirstName + ' ' + CD.MiddleName + ' ' + CD.LastName END DESC,
  CASE  WHEN @OrderBy=1 THEN CD.MobileNumber END DESC,
  CASE  WHEN @OrderBy=2 THEN  ISNULL(CD.AddressLine1,'') + IIF(CD.AddressLine1 IS NULL,'',', ') + ISNULL(CD.AddressLine2,'') + IIF(CD.AddressLine2 IS NULL,'',', ') + CD.TalukaName + ', ' + CD.DistrictName + IIF(CD.ZipCode IS NULL,'',', ' + CD.ZipCode) END DESC, 
  CASE  WHEN @OrderBy=3 THEN CD.EmailId END DESC,
  CASE  WHEN @OrderBy=4 THEN CD.DrivingLicenceNumber END DESC,  
  CASE  WHEN @OrderBy=5 THEN CD.ValidTill END DESC,
  CASE  WHEN @OrderBy=6 THEN CD.AppAccessMobileNo END DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                  
                              
                                
 END
 ELSE
 BEGIN
 
  SELECT 
  CD.CabDriverId,
  CD.FirstName + ' ' + CD.MiddleName + ' ' + CD.LastName as 'FullName'
  , CD.MobileNumber
  , ISNULL(CD.AddressLine1,'') + IIF(CD.AddressLine1 IS NULL,'',', ') + ISNULL(CD.AddressLine2,'') + IIF(CD.AddressLine2 IS NULL,'',', ') + CD.TalukaName + ', ' + CD.DistrictName + IIF(CD.ZipCode IS NULL,'',', ' + CD.ZipCode) AS 'Address'
  ,CD.EmailId, CD.DrivingLicenceNumber, CD.ValidTill,CD.AppAccessMobileNo
  FROM CabDriver CD
  WHERE
     ISNULL(CD.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (CD.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (CD.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.EmailId LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.DrivingLicenceNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.ValidTill LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (CD.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (CD.DistrictName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (CD.AppAccessMobileNo LIKE '%'+@SearchText+'%')

  ))
ORDER BY
  CASE  WHEN @OrderBy=0 THEN CD.FirstName + ' ' + CD.MiddleName + ' ' + CD.LastName END ASC,
  CASE  WHEN @OrderBy=1 THEN CD.MobileNumber END ASC,
  CASE  WHEN @OrderBy=2 THEN ISNULL(CD.AddressLine1,'') + IIF(CD.AddressLine1 IS NULL,'',', ') + ISNULL(CD.AddressLine2,'') + IIF(CD.AddressLine2 IS NULL,'',', ') + CD.TalukaName + ', ' + CD.DistrictName + IIF(CD.ZipCode IS NULL,'',', ' + CD.ZipCode)
 END ASC, 
  CASE  WHEN @OrderBy=3 THEN CD.EmailId END ASC,
  CASE  WHEN @OrderBy=4 THEN CD.DrivingLicenceNumber END ASC,  
  CASE  WHEN @OrderBy=5 THEN CD.ValidTill END ASC,
  CASE  WHEN @OrderBy=6 THEN CD.AppAccessMobileNo END ASC
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