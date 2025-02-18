-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 24/08/2024
-- Description:  This stored procedure is used to get class exam mapping info
-- =============================================
CREATE PROC [dbo].[uspClassExamMappingGridSelect](@RequestModel NVARCHAR(MAX)
) AS Begin
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

 SELECT COUNT(em.ExamMasterId)
 FROM CBSE_ExamMaster em
 INNER JOIN CBSE_ExamType et ON et.ExamTypeId = em.ExamTypeId 
 INNER JOIN CBSE_Term t ON t.TermId = em.TermId 
 WHERE
   ISNULL(em.IsDeleted,0)<>1 and  ISNULL(et.IsDeleted,0)<>1 and  ISNULL(t.IsDeleted,0)<>1 and em.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR LEN(@SearchText) > 0 AND (em.ExamName LIKE '%' + @SearchText + '%'
   OR LEN(@SearchText) > 0 AND (et.ExamTypeName LIKE '%' + @SearchText + '%')
   OR LEN(@SearchText) > 0 AND (t.TermName LIKE '%' + @SearchText + '%')
   ));

 IF(@OrderBy_ASC_DESC='desc')
 BEGIN

 SELECT 
    em.ExamMasterId,
    em.ExamName,
    em.ExamTypeId,
    et.ExamTypeName,
    em.TermId,
    t.TermName,
	(SELECT 
     STRING_AGG(CAST(sgdm.SchoolGradeDivisionMatrixId AS NVARCHAR(10)), ', ')
 FROM 
     CBSE_ClassExamMapping cem
 INNER JOIN 
     SchoolGradeDivisionMatrix sgdm ON sgdm.GradeId = cem.GradeId 
     AND sgdm.DivisionId = cem.DivisionId 
     AND cem.IsDeleted<>1
 WHERE 
 ISNULL(sgdm.IsDeleted,0)<>1 
     AND  ISNULL(cem.IsDeleted,0)<>1 
     AND cem.ExamMasterId = em.ExamMasterId
	 AND cem.IsDeleted <> 1 
     AND sgdm.AcademicYearId = @AcademicYearId 
     AND cem.AcademicYearId=@AcademicYearId
) AS ClassIds
        
  FROM CBSE_ExamMaster em
  INNER JOIN CBSE_ExamType et ON et.ExamTypeId = em.ExamTypeId 
  INNER JOIN CBSE_Term t ON t.TermId = em.TermId 
  WHERE
    ISNULL(em.IsDeleted,0)<>1 
    AND ISNULL(et.IsDeleted,0)<>1
    AND ISNULL(t.IsDeleted,0)<>1
    AND em.AcademicYearId = @AcademicYearId
	AND (LEN(@SearchText)=0 
   OR LEN(@SearchText) > 0 AND (em.ExamName LIKE '%' + @SearchText + '%'
   OR LEN(@SearchText) > 0 AND (et.ExamTypeName LIKE '%' + @SearchText + '%')
   OR LEN(@SearchText) > 0 AND (t.TermName LIKE '%' + @SearchText + '%')
   ))


  ORDER BY
  CASE WHEN @OrderBy = 0 THEN et.ExamTypeName END DESC,
  CASE WHEN @OrderBy = 1 THEN t.TermName END DESC,
  CASE WHEN @OrderBy = 2 THEN em.ExamName END DESC
  OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
  END
  ELSE
  BEGIN

  SELECT 
    em.ExamMasterId,
    em.ExamName,
    em.ExamTypeId,
    et.ExamTypeName,
    em.TermId,
    t.TermName,
		(SELECT 
     STRING_AGG(CAST(sgdm.SchoolGradeDivisionMatrixId AS NVARCHAR(10)), ', ')
 FROM 
     SchoolGradeDivisionMatrix sgdm
INNER JOIN 
     CBSE_ClassExamMapping cem ON sgdm.GradeId = cem.GradeId 
     AND sgdm.DivisionId = cem.DivisionId
 WHERE 
     cem.ExamMasterId = em.ExamMasterId
	  AND cem.IsDeleted <> 1 
	  AND sgdm.IsDeleted <> 1 
      AND sgdm.AcademicYearId = @AcademicYearId 
      AND cem.AcademicYearId=@AcademicYearId
) AS ClassIds

  FROM CBSE_ExamMaster em
   INNER JOIN CBSE_ExamType et ON et.ExamTypeId = em.ExamTypeId 
   INNER JOIN CBSE_Term t ON t.TermId = em.TermId 
  WHERE
    ISNULL(em.IsDeleted,0)<>1  
    AND ISNULL(et.IsDeleted,0)<>1
    AND ISNULL(t.IsDeleted,0)<>1
    AND em.AcademicYearId = @AcademicYearId
	AND (LEN(@SearchText)=0 
       OR LEN(@SearchText) > 0 AND (em.ExamName LIKE '%' + @SearchText + '%'
   OR LEN(@SearchText) > 0 AND (et.ExamTypeName LIKE '%' + @SearchText + '%')
   OR LEN(@SearchText) > 0 AND (t.TermName LIKE '%' + @SearchText + '%')
   ))

  ORDER BY
  CASE WHEN @OrderBy = 0 THEN et.ExamTypeName END ASC,
  CASE WHEN @OrderBy = 1 THEN t.TermName END ASC,
  CASE WHEN @OrderBy = 2 THEN em.ExamName END ASC
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
@ErrorState END CATCH END