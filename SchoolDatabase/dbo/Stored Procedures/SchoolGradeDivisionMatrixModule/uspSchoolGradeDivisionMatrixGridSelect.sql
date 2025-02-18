-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 23/08/2023
-- Description:  This stored procedure is used to get school grade division matrix info
-- =============================================
CREATE PROC [dbo].[uspSchoolGradeDivisionMatrixGridSelect](@RequestModel NVARCHAR(MAX)) AS Begin
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
 
    ;WITH CTE1 AS
     (SELECT sgdm.GradeId, g.GradeName,d.DivisionName
     FROM SchoolGradeDivisionMatrix sgdm
     JOIN Grade g ON sgdm.GradeId=g.GradeId
     JOIN Division d ON sgdm.DivisionId=d.DivisionId
     WHERE ISNULL(sgdm.IsDeleted,0)<>1 and sgdm.AcademicYearId = @AcademicYearId
    ),
    CTE2(GradeId,GradeDivisions) AS 
    (
     SELECT
     GradeId,STRING_AGG(CONCAT(GradeName,' '+DivisionName),',')
     FROM CTE1
      GROUP BY GradeId
    )SELECT COUNT(GradeId) FROM CTE2
     WHERE (LEN(@SearchText)=0 OR
      LEN(@SearchText)>0 AND  (GradeDivisions LIKE +@SearchText+'%'));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN

   ;WITH CTE1 AS
     (SELECT sgdm.GradeId, g.GradeName,d.DivisionName
     FROM SchoolGradeDivisionMatrix sgdm
     JOIN Grade g ON sgdm.GradeId=g.GradeId
     JOIN Division d ON sgdm.DivisionId=d.DivisionId
     WHERE ISNULL(sgdm.IsDeleted,0)<>1 and sgdm.AcademicYearId = @AcademicYearId
    ),
    CTE2(GradeId,GradeName,GradeDivisions) AS 
    (
     SELECT
     GradeId,GradeName,STRING_AGG(CONCAT(GradeName,' '+DivisionName),',')
     FROM CTE1
      GROUP BY GradeId,GradeName
    )SELECT GradeId,GradeName,GradeDivisions FROM CTE2
     WHERE (LEN(@SearchText)=0 OR
      LEN(@SearchText)>0 AND  (GradeDivisions LIKE +@SearchText+'%'))
    ORDER BY
		--CASE WHEN @OrderBy=0 THEN GradeName END DESC
		 CASE WHEN ISNUMERIC(GradeName) = 1 THEN 0 ELSE 1 END,
                CASE WHEN ISNUMERIC(GradeName) = 1 THEN CAST(GradeName AS INT) ELSE 0 END DESC,
                GradeName DESC
    OFFSET @PageNumber ROWS
    FETCH NEXT @PageSize ROWS ONLY;



                                                           
 END
 ELSE
 BEGIN
                           
         
  ;WITH CTE1 AS
     (SELECT sgdm.GradeId, g.GradeName,d.DivisionName
     FROM SchoolGradeDivisionMatrix sgdm
     JOIN Grade g ON sgdm.GradeId=g.GradeId
     JOIN Division d ON sgdm.DivisionId=d.DivisionId
     WHERE ISNULL(sgdm.IsDeleted,0)<>1 and sgdm.AcademicYearId = @AcademicYearId
    ),
    CTE2(GradeId,GradeName,GradeDivisions) AS 
    (
     SELECT
     GradeId,GradeName,STRING_AGG(CONCAT(GradeName,' '+DivisionName),',')
     FROM CTE1
      GROUP BY GradeId,GradeName
    )SELECT GradeId,GradeName,GradeDivisions FROM CTE2
     WHERE (LEN(@SearchText)=0 OR
      LEN(@SearchText)>0 AND  (GradeDivisions LIKE +@SearchText+'%'))
    ORDER BY
		 --CASE  WHEN @OrderBy=0 THEN GradeName END  ASC
		   CASE WHEN ISNUMERIC(GradeName) = 1 THEN 0 ELSE 1 END,
                CASE WHEN ISNUMERIC(GradeName) = 1 THEN CAST(GradeName AS INT) ELSE 0 END ASC,
                GradeName ASC
    OFFSET @PageNumber ROWS
    FETCH NEXT @PageSize ROWS ONLY;


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