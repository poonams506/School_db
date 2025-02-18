-- =============================================
-- Author: Saurabh Walunj 
-- Create date: 28/08/2024
-- Description:  This stored procedure is used to get Exam Report Card info in Grid
-- =============================================
CREATE PROCEDURE [dbo].[uspExamReportCardGridSelect](@RequestModel NVARCHAR(MAX)) AS Begin
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
 
  SELECT COUNT (DISTINCT er.ExamReportCardNameId)

   FROM CBSE_ExamReportCardName er
    INNER JOIN CBSE_ReportCardExam rcm ON er.ExamReportCardNameId = rcm.ExamReportCardNameId
    INNER JOIN CBSE_Term t ON rcm.TermId = t.TermId
    INNER JOIN CBSE_ExamMaster em ON rcm.ExamMasterId = em.ExamMasterId
    INNER JOIN CBSE_ReportCardClasses cm ON er.ExamReportCardNameId = cm.ExamReportCardNameId
    INNER JOIN Grade g ON cm.GradeId = g.GradeId
    INNER JOIN Division d ON cm.DivisionId = d.DivisionId

  WHERE
 er.IsDeleted <> 1
AND er.AcademicYearId = @AcademicYearId
AND   ISNULL(er.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (er.ReportCardName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (rcm.TermId LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (er.Description LIKE '%'+@SearchText+'%')
     ));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
   WITH CTE1 AS(                       
  SELECT DISTINCT
    er.ReportCardName,
	er.ExamReportCardNameId,
    --rcm.TermId,
	er.CreatedDate,
	er.Description,
    STUFF(
        (
            SELECT  
                ', ' + em2.ExamName
            FROM CBSE_ReportCardExam rcm2
            INNER JOIN CBSE_Term t2 ON rcm2.TermId = t2.TermId
            INNER JOIN CBSE_ExamMaster em2 ON rcm2.ExamMasterId = em2.ExamMasterId
            WHERE --rcm2.TermId = rcm.TermId 
             rcm2.ExamReportCardNameId = er.ExamReportCardNameId
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)')
    , 1, 2, '') AS ExamNames,
    er.IsTwoDifferentExamSection,
    (
        SELECT STRING_AGG(CAST(sgdm.SchoolGradeDivisionMatrixId AS NVARCHAR(10)), ', ')
        FROM CBSE_ReportCardClasses rcc
        INNER JOIN SchoolGradeDivisionMatrix sgdm ON sgdm.GradeId = rcc.GradeId 
        AND sgdm.DivisionId = rcc.DivisionId 
        WHERE ISNULL(rcc.IsDeleted, 0) = 0 
        AND ISNULL(sgdm.IsDeleted, 0) = 0
        AND rcc.ExamReportCardNameId = er.ExamReportCardNameId
        AND sgdm.AcademicYearId = @AcademicYearId
        AND rcc.AcademicYearId = @AcademicYearId
    ) AS ClassIds,
	STUFF(
        (
            SELECT  
                ', ' + g.GradeName+'-'+d.DivisionName
            FROM CBSE_ReportCardClasses rcc
        INNER JOIN SchoolGradeDivisionMatrix sgdm ON sgdm.GradeId = rcc.GradeId AND sgdm.AcademicYearId=@AcademicYearId
		INNER JOIN Grade g ON rcc.GradeId=g.GradeId
		INNER JOIN Division d ON rcc.DivisionId=d.DivisionId
        AND sgdm.DivisionId = rcc.DivisionId 
        WHERE ISNULL(rcc.IsDeleted, 0) = 0 
        AND ISNULL(sgdm.IsDeleted, 0) = 0
        AND rcc.ExamReportCardNameId = er.ExamReportCardNameId
        AND sgdm.AcademicYearId = @AcademicYearId
        AND rcc.AcademicYearId = @AcademicYearId
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)')
    , 1, 2, '') AS ClassNames
FROM CBSE_ExamReportCardName er
INNER JOIN CBSE_ReportCardExam rcm ON er.ExamReportCardNameId = rcm.ExamReportCardNameId
INNER JOIN CBSE_Term t ON rcm.TermId = t.TermId
INNER JOIN CBSE_ExamMaster em ON rcm.ExamMasterId = em.ExamMasterId
INNER JOIN CBSE_ReportCardClasses cm ON er.ExamReportCardNameId = cm.ExamReportCardNameId
INNER JOIN Grade g ON cm.GradeId = g.GradeId
INNER JOIN Division d ON cm.DivisionId = d.DivisionId

WHERE
er.IsDeleted <> 1
AND er.AcademicYearId = @AcademicYearId 
AND   ISNULL(er.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (er.ReportCardName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (rcm.TermId LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (er.Description LIKE '%'+@SearchText+'%')
   ))

   GROUP BY
    er.ReportCardName,
    --rcm.TermId,
	er.Description,
    rcm.ExamMasterId,
    er.IsTwoDifferentExamSection,
    er.ExamReportCardNameId,
	er.CreatedDate
)
SELECT * FROM CTE1
ORDER BY
  CASE  WHEN @OrderBy=3 THEN CreatedDate END DESC,
   CASE  WHEN @OrderBy=0 THEN ReportCardName END DESC
  --CASE  WHEN @OrderBy=1 THEN Description END DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                                             
 END
 ELSE
 BEGIN
 WITH CTE2 AS (
   SELECT DISTINCT
    er.ReportCardName,
	er.ExamReportCardNameId,
    --rcm.TermId,
	er.CreatedDate,
	er.Description,
    STUFF(
        (
            SELECT  
                ', ' + em2.ExamName
            FROM CBSE_ReportCardExam rcm2
            INNER JOIN CBSE_Term t2 ON rcm2.TermId = t2.TermId
            INNER JOIN CBSE_ExamMaster em2 ON rcm2.ExamMasterId = em2.ExamMasterId
            WHERE --rcm2.TermId = rcm.TermId 
             rcm2.ExamReportCardNameId = er.ExamReportCardNameId
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)')
    , 1, 2, '') AS ExamNames,
    er.IsTwoDifferentExamSection,
    (
        SELECT STRING_AGG(CAST(sgdm.SchoolGradeDivisionMatrixId AS NVARCHAR(10)), ', ')
        FROM CBSE_ReportCardClasses rcc
        INNER JOIN SchoolGradeDivisionMatrix sgdm ON sgdm.GradeId = rcc.GradeId 
        AND sgdm.DivisionId = rcc.DivisionId 
        WHERE ISNULL(rcc.IsDeleted, 0) = 0 
        AND ISNULL(sgdm.IsDeleted, 0) = 0
        AND rcc.ExamReportCardNameId = er.ExamReportCardNameId
        AND sgdm.AcademicYearId = @AcademicYearId
        AND rcc.AcademicYearId = @AcademicYearId
    ) AS ClassIds,
	STUFF(
        (
            SELECT  
                ', ' + g.GradeName+'-'+d.DivisionName
            FROM CBSE_ReportCardClasses rcc
        INNER JOIN SchoolGradeDivisionMatrix sgdm ON sgdm.GradeId = rcc.GradeId AND sgdm.AcademicYearId=@AcademicYearId
		INNER JOIN Grade g ON rcc.GradeId=g.GradeId
		INNER JOIN Division d ON rcc.DivisionId=d.DivisionId
        AND sgdm.DivisionId = rcc.DivisionId 
        WHERE ISNULL(rcc.IsDeleted, 0) = 0 
        AND ISNULL(sgdm.IsDeleted, 0) = 0
        AND rcc.ExamReportCardNameId = er.ExamReportCardNameId
        AND sgdm.AcademicYearId = @AcademicYearId
        AND rcc.AcademicYearId = @AcademicYearId
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)')
    , 1, 2, '') AS ClassNames

FROM CBSE_ExamReportCardName er
INNER JOIN CBSE_ReportCardExam rcm ON er.ExamReportCardNameId = rcm.ExamReportCardNameId
INNER JOIN CBSE_Term t ON rcm.TermId = t.TermId
INNER JOIN CBSE_ExamMaster em ON rcm.ExamMasterId = em.ExamMasterId
INNER JOIN CBSE_ReportCardClasses cm ON er.ExamReportCardNameId = cm.ExamReportCardNameId
INNER JOIN Grade g ON cm.GradeId = g.GradeId
INNER JOIN Division d ON cm.DivisionId = d.DivisionId

  WHERE
er.IsDeleted <> 1
AND er.AcademicYearId = @AcademicYearId 
AND   ISNULL(er.IsDeleted,0)<>1 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND  (er.ReportCardName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (rcm.TermId LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (er.Description LIKE '%'+@SearchText+'%')
   )
   )

   GROUP BY
    er.ReportCardName,
    --rcm.TermId,
	er.Description,
    rcm.ExamMasterId,
    er.IsTwoDifferentExamSection,
    er.ExamReportCardNameId,
	er.CreatedDate
	)
	SELECT * FROM CTE2 
ORDER BY
  CASE  WHEN @OrderBy=3 THEN CreatedDate END ASC,
 CASE  WHEN @OrderBy=0 THEN ReportCardName END ASC

   --CASE  WHEN @OrderBy=1 THEN Description END ASC
 
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