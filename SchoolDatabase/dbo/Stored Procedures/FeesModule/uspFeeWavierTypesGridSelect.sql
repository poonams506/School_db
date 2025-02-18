-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 25/09/2023
-- Description:  This stored procedure is used to get FeeWavierType for grid
-- =============================================

CREATE PROC uspFeeWavierTypeGridSelect
( 
 @RequestModel NVARCHAR(MAX)
) 
AS BEGIN
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
 
  SELECT COUNT(F.FeeWavierTypeId)
  FROM FeeWavierTypes  F
  WHERE
    ISNULL(F.IsDeleted,0)<>1 AND F.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (F.FeeWavierTypeName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (F.FeeWavierDisplayName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (F.[Description] LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (F.IsActive LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (F.NumberOfInstallments LIKE '%'+@SearchText+'%')
   ));
 

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT F.FeeWavierTypeId,
     F.FeeWavierTypeName,
     F.FeeWavierDisplayName,
     F.[Description],
     F.DiscountInPercent*100 AS DiscountInPercent,
     F.LatePerDayFeeInPercent*100 AS LatePerDayFeeInPercent,
     F.CategoryId,
     F.NumberOfInstallments,
     CASE WHEN F.IsActive = 1 THEN 'Y'
          WHEN F.IsActive = 0 THEN 'N'
          END AS 'IsActive'
 FROM FeeWavierTypes F
 WHERE
 ISNULL(F.IsDeleted,0)<>1 AND F.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (F.FeeWavierTypeName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (F.FeeWavierDisplayName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (F.[Description] LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (F.IsActive LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (F.NumberOfInstallments LIKE '%'+@SearchText+'%')
   ))
 ORDER BY
 CASE WHEN @OrderBy=0 THEN F.FeeWavierTypeName END DESC,
 CASE WHEN @OrderBy=1 THEN F.FeeWavierDisplayName END DESC,
 CASE WHEN @OrderBy=2 THEN F.Description END DESC,
 CASE WHEN @OrderBy=3 THEN F.DiscountInPercent END DESC,
 CASE WHEN @OrderBy=4 THEN F.LatePerDayFeeInPercent END DESC,
 CASE WHEN @OrderBy=5 THEN F.NumberOfInstallments END DESC,
 CASE WHEN @OrderBy=6 THEN F.IsActive END DESC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
END
ELSE
  BEGIN
                           
         
 SELECT F.FeeWavierTypeId,
     F.FeeWavierTypeName,
     F.FeeWavierDisplayName,
     F.[Description],
     F.DiscountInPercent*100 AS DiscountInPercent,
     F.LatePerDayFeeInPercent*100 AS LatePerDayFeeInPercent,
     F.CategoryId,
     F.NumberOfInstallments,
     CASE WHEN F.IsActive = 1 THEN 'Y'
          WHEN F.IsActive = 0 THEN 'N'
          END AS 'IsActive'
 FROM FeeWavierTypes F
 WHERE
 ISNULL(F.IsDeleted,0)<>1 AND F.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (F.FeeWavierTypeName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (F.FeeWavierDisplayName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (F.[Description] LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (F.IsActive LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (F.NumberOfInstallments LIKE '%'+@SearchText+'%')
   ))
 ORDER BY
 CASE WHEN @OrderBy=0 THEN F.FeeWavierTypeName END ASC,
 CASE WHEN @OrderBy=1 THEN F.FeeWavierDisplayName END ASC,
 CASE WHEN @OrderBy=2 THEN F.Description END ASC,
 CASE WHEN @OrderBy=3 THEN F.DiscountInPercent END ASC,
 CASE WHEN @OrderBy=4 THEN F.LatePerDayFeeInPercent END ASC,
 CASE WHEN @OrderBy=5 THEN F.NumberOfInstallments END ASC,
 CASE WHEN @OrderBy=6 THEN F.IsActive END ASC
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



