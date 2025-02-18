-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 05/01/2024
-- Description:  This stored procedure is used to get class time table grid data
-- =============================================
CREATE PROC uspClassTimeTableGridSelect(@RequestModel NVARCHAR(MAX)) AS BEGIN
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

 SELECT 
       COUNT(sgdm.SchoolGradeDivisionMatrixId)
  FROM dbo.SchoolGradeDivisionMatrix sgdm JOIN 
        dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
        dbo.Division d ON sgdm.DivisionId=d.DivisionId 
        WHERE sgdm.AcademicYearId = @AcademicYearId AND
        sgdm.IsDeleted <> 1 AND
        EXISTS(SELECT TOP (1) clt.ClassTimeTableId FROM 
            dbo.ClassTimeTable clt 
            WHERE g.GradeId=clt.GradeId AND
            d.DivisionId=clt.DivisionId AND
            clt.AcademicYearId=@AcademicYearId AND
            clt.isDeleted<>1
            )
      AND (LEN(@SearchText)=0 OR
      LEN(@SearchText)>0 AND  (CONCAT(g.GradeName ,' - ' ,d.DivisionName) LIKE +@SearchText+'%'))
 
 
  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
   
SELECT 
       sgdm.SchoolGradeDivisionMatrixId AS ClassId,
       CONCAT(g.GradeName ,' - ' ,d.DivisionName) AS ClassName
  FROM dbo.SchoolGradeDivisionMatrix sgdm JOIN 
        dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
        dbo.Division d ON sgdm.DivisionId=d.DivisionId 
        WHERE sgdm.AcademicYearId = @AcademicYearId AND
        sgdm.IsDeleted<>1 AND
            EXISTS(SELECT TOP (1) clt.ClassTimeTableId FROM 
            dbo.ClassTimeTable clt 
            WHERE g.GradeId=clt.GradeId AND
            d.DivisionId=clt.DivisionId AND
            clt.AcademicYearId=@AcademicYearId AND
            clt.isDeleted<>1
            )
      AND (LEN(@SearchText)=0 OR
      LEN(@SearchText)>0 AND  (CONCAT(g.GradeName ,' - ' ,d.DivisionName) LIKE +@SearchText+'%'))
ORDER BY
    CASE  WHEN @OrderBy=0 THEN len(CONCAT(g.GradeName ,' - ' ,d.DivisionName)) END DESC, CONCAT(g.GradeName ,' - ' ,d.DivisionName) DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY

  ;WITH CTE AS ( SELECT 
       sgdm.SchoolGradeDivisionMatrixId AS ClassId,
       g.GradeId,
       d.DivisionId
  FROM dbo.SchoolGradeDivisionMatrix sgdm JOIN 
        dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
        dbo.Division d ON sgdm.DivisionId=d.DivisionId 
        WHERE sgdm.AcademicYearId = @AcademicYearId AND
        sgdm.IsDeleted<>1 AND
            EXISTS(SELECT TOP (1) clt.ClassTimeTableId FROM 
            dbo.ClassTimeTable clt 
            WHERE g.GradeId=clt.GradeId AND
            d.DivisionId=clt.DivisionId AND
            clt.AcademicYearId=@AcademicYearId AND
            clt.isDeleted<>1)
      AND (LEN(@SearchText)=0 OR
      LEN(@SearchText)>0 AND  (CONCAT(g.GradeName ,' - ' ,d.DivisionName) LIKE +@SearchText+'%'))
ORDER BY
    CASE  WHEN @OrderBy=0 THEN len(CONCAT(g.GradeName ,' - ' ,d.DivisionName)) END DESC, CONCAT(g.GradeName ,' - ' ,d.DivisionName) DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
  ) SELECT  c.ClassId,clt.ClassTimeTableId,clt.ClassTimeTableName,clt.IsActive FROM CTE c JOIN
  dbo.ClassTimeTable clt ON c.GradeId=clt.GradeId AND c.DivisionId=clt.DivisionId
  AND clt.AcademicYearId=@AcademicYearId;
  
 END
 ELSE
 BEGIN
 
   SELECT 
       sgdm.SchoolGradeDivisionMatrixId AS ClassId,
       CONCAT(g.GradeName ,' - ' ,d.DivisionName) AS ClassName
  FROM dbo.SchoolGradeDivisionMatrix sgdm JOIN 
        dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
        dbo.Division d ON sgdm.DivisionId=d.DivisionId 
        WHERE sgdm.AcademicYearId = @AcademicYearId AND
        sgdm.IsDeleted<>1 AND
            EXISTS(SELECT TOP (1) clt.ClassTimeTableId FROM 
            dbo.ClassTimeTable clt 
            WHERE g.GradeId=clt.GradeId AND
            d.DivisionId=clt.DivisionId AND
            clt.AcademicYearId=@AcademicYearId AND
            clt.isDeleted<>1)
      AND (LEN(@SearchText)=0 OR
      LEN(@SearchText)>0 AND  (CONCAT(g.GradeName ,' - ' ,d.DivisionName) LIKE +@SearchText+'%'))
ORDER BY
    CASE  WHEN @OrderBy=0 THEN len(CONCAT(g.GradeName ,' - ' ,d.DivisionName)) END ASC, CONCAT(g.GradeName ,' - ' ,d.DivisionName) ASC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY

  ;WITH CTE AS ( SELECT 
       sgdm.SchoolGradeDivisionMatrixId AS ClassId,
       g.GradeId,
       d.DivisionId
  FROM dbo.SchoolGradeDivisionMatrix sgdm JOIN 
        dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
        dbo.Division d ON sgdm.DivisionId=d.DivisionId 
        WHERE sgdm.AcademicYearId = @AcademicYearId AND
        sgdm.IsDeleted<>1 AND
            EXISTS(SELECT TOP (1) clt.ClassTimeTableId FROM 
            dbo.ClassTimeTable clt 
            WHERE g.GradeId=clt.GradeId AND
            d.DivisionId=clt.DivisionId AND
            clt.AcademicYearId=@AcademicYearId AND
            clt.isDeleted<>1)
      AND (LEN(@SearchText)=0 OR
      LEN(@SearchText)>0 AND  (CONCAT(g.GradeName ,' - ' ,d.DivisionName) LIKE +@SearchText+'%'))
ORDER BY
    CASE  WHEN @OrderBy=0 THEN len(CONCAT(g.GradeName ,' - ' ,d.DivisionName)) END ASC, CONCAT(g.GradeName ,' - ' ,d.DivisionName) ASC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
  ) SELECT  c.ClassId,clt.ClassTimeTableId,clt.ClassTimeTableName,clt.IsActive FROM CTE c JOIN
  dbo.ClassTimeTable clt ON c.GradeId=clt.GradeId AND c.DivisionId=clt.DivisionId
  AND clt.AcademicYearId=@AcademicYearId AND clt.isDeleted<>1;

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