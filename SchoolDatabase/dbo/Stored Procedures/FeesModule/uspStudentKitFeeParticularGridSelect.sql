-- =============================================
-- Author:    SA
-- Create date: 25/09/2023
-- Description:  This stored procedure is used to get Fee particulars for grid
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentKitFeeParticularGridSelect]
	@RequestModel NVARCHAR(MAX)
AS
BEGIN
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
 
  SELECT COUNT(M.GradeId)
  FROM dbo.SchoolGradeDivisionMatrix M
      INNER JOIN dbo.Grade G
      ON M.GradeId = G.GradeId
      INNER JOIN dbo.Division D
      ON M.DivisionId = D.DivisionId
	 OUTER APPLY (SELECT TOP (1) FeeParticularId,IsPublished 
                    FROM dbo.StudentKitFeeParticular 
                    WHERE GradeId=M.GradeId   AND DivisionId = M.DivisionId 
                  AND AcademicYearId = @AcademicYearId AND  IsDeleted <>1 
                  ORDER BY CreatedDate DESC) F
    OUTER APPLY (SELECT TOP (1) fp.StudentKitFeePaymentDetailId 
                    FROM dbo.StudentKitFeePaymentDetails fp WHERE
                    fp.FeeParticularId=F.FeeParticularId 
                    AND fp.AcademicYearId=@AcademicYearId
                    AND fp.IsDeleted<>1 ORDER BY CreatedDate DESC) AS fp
     
 WHERE
   M.IsDeleted <> 1 AND M.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 
        AND (G.GradeName + ' - ' + D.DivisionName LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 
        AND (ISNULL(IIF(F.IsPublished = 1,'Published','Created'),'Not-Created') LIKE '%'+@SearchText+'%')
   ));
 

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT 
     M.SchoolGradeDivisionMatrixId AS ClassId,
     G.GradeId,
     M.DivisionId,
     G.GradeName + ' - ' + D.DivisionName  AS GradeName,
     CASE WHEN F.IsPublished = 1 THEN 'Published'
          WHEN F.IsPublished = 0 THEN 'Created'
          ELSE 'Not-Created'
          END AS Status,
    CASE WHEN fp.StudentKitFeePaymentDetailId IS NOT NULL THEN 1
         ELSE 0 END AS IsFeePaymentAlreadyDone
   FROM dbo.SchoolGradeDivisionMatrix M
      INNER JOIN dbo.Grade G
      ON M.GradeId = G.GradeId
      INNER JOIN dbo.Division D
      ON M.DivisionId = D.DivisionId
	 OUTER APPLY (SELECT TOP (1) FeeParticularId,IsPublished 
                   FROM dbo.StudentKitFeeParticular  WHERE GradeId=M.GradeId  
                  AND DivisionId = M.DivisionId 
                  AND AcademicYearId = @AcademicYearId AND  IsDeleted <>1 
                  ORDER BY CreatedDate DESC) F
     OUTER APPLY (SELECT TOP (1) FP.StudentKitFeePaymentDetailId 
                    FROM dbo.StudentKitFeePaymentDetails fp WHERE
                    fp.FeeParticularId=F.FeeParticularId 
                    AND fp.AcademicYearId=@AcademicYearId
                    AND fp.IsDeleted<>1 ORDER BY CreatedDate) AS fp
     
 WHERE
   M.IsDeleted <> 1 and M.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 
       AND (G.GradeName + ' - ' + D.DivisionName LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 
       AND (ISNULL(IIF(F.IsPublished = 1,'Published','Created'),'Not-Created') LIKE '%'+@SearchText+'%')
   ))
 
 ORDER BY
 CASE WHEN @OrderBy=0 THEN len(G.GradeName + ' - ' + D.DivisionName) END DESC, G.GradeName + ' - ' + D.DivisionName DESC,
 CASE WHEN @OrderBy=1 THEN F.IsPublished END DESC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
END
ELSE
  BEGIN
                           
         
 SELECT 
     M.SchoolGradeDivisionMatrixId AS ClassId,
     G.GradeId,
     M.DivisionId,
     G.GradeName + ' - ' + D.DivisionName  AS GradeName,
     CASE WHEN F.IsPublished = 1 THEN 'Published'
          WHEN F.IsPublished = 0 THEN 'Created'
          ELSE 'Not-Created'
          END AS Status,
     CASE WHEN fp.StudentKitFeePaymentDetailId IS NOT NULL THEN 1
         ELSE 0 END AS IsFeePaymentAlreadyDone
  FROM dbo.SchoolGradeDivisionMatrix M
      INNER JOIN dbo.Grade G
      ON M.GradeId = G.GradeId
      INNER JOIN dbo.Division D
      ON M.DivisionId = D.DivisionId and M.AcademicYearId = @AcademicYearId
	 OUTER APPLY (SELECT TOP (1) FeeParticularId,IsPublished 
                  FROM dbo.StudentKitFeeParticular  WHERE GradeId=M.GradeId  
                  AND DivisionId = M.DivisionId 
                  AND AcademicYearId = @AcademicYearId 
                  AND  IsDeleted <>1 ORDER BY CreatedDate DESC) F
      OUTER APPLY (SELECT TOP (1) FP.StudentKitFeePaymentDetailId 
                    FROM dbo.StudentKitFeePaymentDetails fp WHERE
                    fp.FeeParticularId=F.FeeParticularId 
                    AND fp.AcademicYearId=@AcademicYearId
                    AND fp.IsDeleted<>1 ORDER BY CreatedDate) AS fp
    
    WHERE
   M.IsDeleted <> 1
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 
       AND (G.GradeName + ' - ' + D.DivisionName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 
       AND (ISNULL(IIF(F.IsPublished = 1,'Published','Created'),'Not-Created') LIKE '%'+@SearchText+'%')
   ))
 
 ORDER BY
 CASE WHEN @OrderBy=0 THEN len(G.GradeName + ' - ' + D.DivisionName) END ASC, G.GradeName + ' - ' + D.DivisionName ASC,
 CASE WHEN @OrderBy=1 THEN F.IsPublished END ASC
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
@ErrorState END CATCH
END
