-- =============================================
-- Author:   Chaitanya Kasar
-- Create date: 09/04/2024
-- Description:  This stored procedure is used to get Vehicle grid data
-- =============================================
CREATE PROCEDURE uspSchoolVehicleGridSelect (@RequestModel NVARCHAR(MAX)) AS Begin
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

 
  SELECT COUNT(v.VehicleId)
  FROM Vehicle v
  LEFT JOIN dbo.CabDriver cd ON v.CabDriverId = cd.CabDriverId
  WHERE
   
   ISNULL(v.IsDeleted,0)<>1 
   AND v.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0
  OR  LEN(@SearchText)>0 AND (v.RagistrationNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (v.VehicleNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (v.TotalSeats LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (cd.FirstName LIKE +@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (cd.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (cd.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (v.ProviderName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (IIF( v.IsActive = 1,'Active','InActive') LIKE '%'+@SearchText+'%')
  );

  IF(@OrderBy_Asc_DESC='desc')
 BEGIN
                          
 SELECT 
 v.VehicleId,
 v.AcademicYearId,
 v.RagistrationNumber,
 v.VehicleNumber,
 v.TotalSeats,
 v.CabDriverId,
 CONCAT(cd.FirstName,' ',cd.MiddleName,' ',cd.LastName )as 'CabDriverName',
 v.ProviderName,
CASE WHEN v.IsActive = 1 THEN 'Active'
          WHEN v.IsActive = 0 THEN 'InActive'
          END AS 'Status'
 FROM Vehicle v
   LEFT JOIN dbo.CabDriver cd ON v.CabDriverId = cd.CabDriverId

 WHERE
   
   ISNULL(v.IsDeleted,0)<>1 
   AND v.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0
   OR  LEN(@SearchText)>0 AND (v.RagistrationNumber LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (v.VehicleNumber LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (v.TotalSeats LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (cd.FirstName LIKE +@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (cd.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (cd.LastName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (v.ProviderName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (IIF( v.IsActive = 1,'Active','InActive') LIKE '%'+@SearchText+'%')
  )
ORDER BY
  CASE  WHEN @OrderBy=0 THEN v.RagistrationNumber END DESC,
  CASE  WHEN @OrderBy=1 THEN v.VehicleNumber END DESC,
  CASE  WHEN @OrderBy=2 THEN v.TotalSeats END DESC,
  CASE  WHEN @OrderBy=3 THEN cd.FirstName + ' ' + cd.MiddleName + ' ' + cd.LastName END DESC,
  CASE  WHEN @OrderBy=4 THEN v.ProviderName END DESC,
  CASE  WHEN @OrderBy=5 THEN v.IsActive END DESC

 

OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                  
                              
                                
 END
 ELSE
 BEGIN
 
  SELECT 
 v.VehicleId,
 v.AcademicYearId,
 v.RagistrationNumber,
 v.VehicleNumber,
 v.TotalSeats,
 v.CabDriverId,
 CONCAT(cd.FirstName,' ',cd.MiddleName,' ',cd.LastName )as 'CabDriverName',
 v.ProviderName,
 CASE WHEN v.IsActive = 1 THEN 'Active'
          WHEN v.IsActive = 0 THEN 'InActive'
          END AS 'Status'
 FROM Vehicle v
   LEFT JOIN dbo.CabDriver cd ON v.CabDriverId = cd.CabDriverId

 WHERE
   
   ISNULL(v.IsDeleted,0)<>1 
   AND v.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0
   OR  LEN(@SearchText)>0 AND (v.RagistrationNumber LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (v.VehicleNumber LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (v.TotalSeats LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (cd.FirstName LIKE +@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (cd.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (cd.LastName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (v.ProviderName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (IIF( v.IsActive = 1,'Active','InActive') LIKE '%'+@SearchText+'%')
  )
ORDER BY
  CASE  WHEN @OrderBy=0 THEN v.RagistrationNumber END ASC,
  CASE  WHEN @OrderBy=1 THEN v.VehicleNumber END ASC,
  CASE  WHEN @OrderBy=2 THEN v.TotalSeats END ASC,
  CASE  WHEN @OrderBy=3 THEN cd.FirstName + ' ' + cd.MiddleName + ' ' + cd.LastName END ASC,
  CASE  WHEN @OrderBy=4 THEN v.ProviderName END ASC,
  CASE  WHEN @OrderBy=5 THEN v.IsActive END ASC
 
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
