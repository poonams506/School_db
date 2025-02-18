-- =============================================
-- Author:   Swapnil Bhaskar
-- Create date: 15/08/2023
-- Description:  This stored procedure is used to get Teacher info in Grid
-- =============================================
CREATE PROC [dbo].[uspTeacherGridSelect](@RequestModel NVARCHAR(MAX)) AS Begin
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
 
  SELECT COUNT(T.TeacherId)
  FROM dbo.Teacher T
 
  WHERE
    ISNULL(T.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (T.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (T.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.Gender LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.EmailId LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (T.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.DistrictName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (T.AppAccessMobileNo LIKE '%'+@SearchText+'%')

  ));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT 
  T.TeacherId,
  T.FirstName + ' ' + T.MiddleName + ' ' + T.LastName as TeacherFullName
  , T.MobileNumber,
  CASE WHEN T.Gender = 'F' THEN 'Female'
          WHEN T.Gender = 'M' THEN 'Male'
          ELSE ''
          END AS Gender
 , ISNULL(T.AddressLine1,'') + IIF(T.AddressLine1 IS NULL,'',', ') + ISNULL(T.AddressLine2,'') + IIF(T.AddressLine2 IS NULL,'',', ') + T.TalukaName + ', ' + T.DistrictName + IIF(T.ZipCode IS NULL,'',', ' + T.ZipCode) AS 'Address'
   ,T.EmailId
   ,T.AppAccessMobileNo
  FROM dbo.Teacher T
  WHERE
     ISNULL(T.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (T.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (T.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.Gender LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.EmailId LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (T.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.DistrictName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.AppAccessMobileNo LIKE '%'+@SearchText+'%')

  ))
ORDER BY
  CASE  WHEN @OrderBy=0 THEN T.FirstName + ' ' + T.MiddleName + ' ' + T.LastName END DESC,
  CASE  WHEN @OrderBy=1 THEN T.Gender END DESC,
  CASE  WHEN @OrderBy=2 THEN T.MobileNumber END DESC,
  CASE  WHEN @OrderBy=3 THEN ISNULL(T.AddressLine1,'') + IIF(T.AddressLine1 IS NULL,'',', ') + ISNULL(T.AddressLine2,'') + IIF(T.AddressLine2 IS NULL,'',', ') + T.TalukaName + ', ' + T.DistrictName + IIF(T.ZipCode IS NULL,'',', ' + T.ZipCode) END DESC, 
  CASE  WHEN @OrderBy=4 THEN T.EmailId END DESC,
  CASE  WHEN @OrderBy=5 THEN T.AppAccessMobileNo END DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                  
                              
                                
 END
 ELSE
 BEGIN
 
  SELECT 
  T.TeacherId,
  T.FirstName + ' ' + T.MiddleName + ' ' + T.LastName as TeacherFullName,
   CASE WHEN T.Gender = 'F' THEN 'Female'
          WHEN T.Gender = 'M' THEN 'Male'
          ELSE ''
          END AS Gender
  , T.MobileNumber
 , ISNULL(T.AddressLine1,'') + IIF(T.AddressLine1 IS NULL,'',', ') + ISNULL(T.AddressLine2,'') + IIF(T.AddressLine2 IS NULL,'',', ') + T.TalukaName + ', ' + T.DistrictName + IIF(T.ZipCode IS NULL,'',', ' + T.ZipCode) AS 'Address'
  ,T.EmailId
  ,T.AppAccessMobileNo
  FROM dbo.Teacher T
  WHERE
     ISNULL(T.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (T.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (T.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.MobileNumber LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (T.Gender LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.ZipCode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.EmailId LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (T.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (T.DistrictName LIKE '%'+@SearchText+'%')
       OR  LEN(@SearchText)>0 AND (T.AppAccessMobileNo LIKE '%'+@SearchText+'%')

  ))
ORDER BY
  CASE  WHEN @OrderBy=0 THEN T.FirstName + ' ' + T.MiddleName + ' ' + T.LastName END ASC,
  CASE  WHEN @OrderBy=1 THEN T.Gender END ASC,
  CASE  WHEN @OrderBy=2 THEN T.MobileNumber END ASC,
  CASE  WHEN @OrderBy=3 THEN ISNULL(T.AddressLine1,'') + IIF(T.AddressLine1 IS NULL,'',', ') + ISNULL(T.AddressLine2,'') + IIF(T.AddressLine2 IS NULL,'',', ') + T.TalukaName + ', ' + T.DistrictName + IIF(T.ZipCode IS NULL,'',', ' + T.ZipCode) END ASC,  
  CASE  WHEN @OrderBy=4 THEN T.EmailId END ASC,
  CASE  WHEN @OrderBy=5 THEN T.AppAccessMobileNo END ASC
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