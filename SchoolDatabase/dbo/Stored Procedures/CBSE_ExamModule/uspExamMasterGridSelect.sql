--===============================================
-- Author:- Prerana Aher
-- Create date:- 25-07-2024
-- Description:-  This stored procedure is used to get Exam Master info in Grid
-- =============================================
CREATE PROCEDURE uspExamMasterGridSelect(@RequestModel NVARCHAR(MAX)) 
AS Begin
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
 DECLARE @CreatedDate DATETIME = GETDATE();

  SELECT COUNT(em.ExamMasterId)
  FROM 
  CBSE_ExamMaster as em
   INNER JOIN CBSE_Term AS t on em.TermId = t.TermId
   INNER JOIN CBSE_ExamType As et on em.ExamTypeId = et.ExamTypeId
 
  WHERE
	em.AcademicYearId = @AcademicYearId AND
    ISNULL(em.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND (em.ExamName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (et.ExamTypeName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (t.TermName LIKE '%'+@SearchText+'%')
);

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT 
 em.ExamMasterId,
 em.ExamName,
 em.ExamTypeId,
 et.ExamTypeName,
 em.TermId,
 t.TermName,
 em.CreatedDate AS CreatedDate

  FROM CBSE_ExamMaster as em
   INNER JOIN CBSE_Term AS t on em.TermId = t.TermId
   INNER JOIN CBSE_ExamType As et on em.ExamTypeId = et.ExamTypeId

  WHERE
   em.AcademicYearId = @AcademicYearId AND
     ISNULL(em.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND (em.ExamName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (et.ExamTypeName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (t.TermName LIKE '%'+@SearchText+'%')
   
  )
ORDER BY
 
  CASE  WHEN @OrderBy=0 THEN et.ExamTypeName END DESC,
  CASE  WHEN @OrderBy=1 THEN t.TermName END DESC,
  CASE  WHEN @OrderBy=2 THEN em.ExamName END DESC,
  CASE  WHEN @OrderBy=3 THEN em.CreatedDate END DESC

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
 em.CreatedDate AS CreatedDate 
 
FROM CBSE_ExamMaster as em
   INNER JOIN CBSE_Term AS t on em.TermId = t.TermId
   INNER JOIN CBSE_ExamType As et on em.ExamTypeId = et.ExamTypeId

 
  WHERE
	em.AcademicYearId = @AcademicYearId AND
    ISNULL(em.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND (em.ExamName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (et.ExamTypeName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (t.TermName LIKE '%'+@SearchText+'%')
)

ORDER BY
  CASE  WHEN @OrderBy=0 THEN et.ExamTypeName END ASC,
  CASE  WHEN @OrderBy=1 THEN t.TermName END ASC,
  CASE  WHEN @OrderBy=2 THEN em.ExamName END ASC,
  CASE  WHEN @OrderBy=3 THEN em.CreatedDate END ASC

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