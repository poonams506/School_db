-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 05/03/2024
-- Description:  This stored procedure is used to get teacher subject mapping info
-- =============================================
CREATE PROC [dbo].[uspTeacherSubjectMappingGridSelect](@RequestModel NVARCHAR(MAX)
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

  SELECT COUNT(t.TeacherId)
  FROM Teacher t
  WHERE
    ISNULL(t.IsDeleted,0)<>1
    AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND  (T.FirstName LIKE +@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (T.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (T.LastName LIKE '%'+@SearchText+'%')));

   IF(@OrderBy_ASC_DESC='desc')
   BEGIN
                          
    SELECT 
    t.TeacherId,
    tad. LecturePerWeek,
    t.FirstName + ' ' + T.MiddleName + ' ' + T.LastName as 'FullName',
	 (SELECT 
     CAST(b.SubjectMasterId as NVARCHAR(50)) + ',' 
 FROM 
     TeacherSubjectMapping b 
 WHERE 
     b.TeacherId = t.TeacherId  AND b.AcademicYearId=@AcademicYearId and b.IsDeleted<>1
FOR XML PATH('')) AS SubjectMasterIds 
    FROM Teacher t
	LEFT JOIN  TeacherAcademicDetail tad ON t.TeacherId = tad.TeacherId AND tad.AcademicYearId=@AcademicYearId
    WHERE
     ISNULL(t.IsDeleted,0)<>1
    AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND  (T.FirstName LIKE +@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (T.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (T.LastName LIKE '%'+@SearchText+'%')))

   ORDER BY
   CASE  WHEN @OrderBy=0 THEN t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName END DESC
  OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
  END
  ELSE
  BEGIN
                          
    SELECT 
    t.TeacherId,
    tad. LecturePerWeek,
    t.FirstName + ' ' + T.MiddleName + ' ' + T.LastName as 'FullName',
	   (SELECT 
     CAST(b.SubjectMasterId as NVARCHAR(50)) + ',' 
 FROM 
     TeacherSubjectMapping b 
 WHERE 
     b.TeacherId = t.TeacherId  AND b.AcademicYearId=@AcademicYearId and b.IsDeleted<>1
FOR XML PATH('')) AS SubjectMasterIds 
    FROM Teacher t
    LEFT JOIN  TeacherAcademicDetail tad ON t.TeacherId = tad.TeacherId AND tad.AcademicYearId=@AcademicYearId
    WHERE
     ISNULL(t.IsDeleted,0)<>1
    AND (LEN(@SearchText)=0 
    OR  LEN(@SearchText)>0 AND  (T.FirstName LIKE +@SearchText+'%'
    OR  LEN(@SearchText)>0 AND (T.MiddleName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (T.LastName LIKE '%'+@SearchText+'%')))

   ORDER BY
    CASE  WHEN @OrderBy=0 THEN t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName END ASC
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
