-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 23/01/2024
-- Description:  This stored procedure is used to get Student Attendance Report info
-- =============================================
CREATE PROC uspStudentAttendanceReportGridSelect (@RequestModel NVARCHAR(MAX))
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
 DECLARE @FromDate DATETIME = JSON_VALUE(@RequestModel, '$.fromDate');
 DECLARE @TillDate DATETIME = JSON_VALUE(@RequestModel, '$.tillDate'); 
 DECLARE @classIds TABLE(Id INT);  
 INSERT INTO @classIds SELECT VALUE FROM OPENJSON(@RequestModel, '$.classIds');
 DECLARE @classIdCount INT= (SELECT COUNT(Id) FROM @classIds);

;WITH CTE AS (
 SELECT COUNT(sa.StudentAttendanceId) AS cnt
   FROM dbo.[StudentAttendance]  AS sa
  INNER JOIN dbo.[StudentGradeDivisionMapping] As sgdm ON sa.StudentId= sgdm.StudentId
  INNER JOIN dbo.[Student] AS s ON sa.StudentId = s.StudentId 
  INNER JOIN dbo.[Grade] g ON sa.GradeId = g.GradeId
  INNER JOIN dbo.[Division] d ON sa.DivisionId = d.DivisionId
  INNER JOIN dbo.[SchoolGradeDivisionMatrix] sgm ON g.GradeId=sgm.GradeId AND d.DivisionId=sgm.DivisionId

   WHERE
   ISNULL(sa.IsDeleted,0)<>1 AND ISNULL(S.IsDeleted,0)<>1  AND ISNULL(S.IsArchive,0)<>1 AND ISNULL(sgm.IsDeleted,0)<>1 AND sgm.AcademicYearId = @AcademicYearId
   AND  (@classIdCount=0 OR  EXISTS (SELECT Id FROM @classIds WHERE Id=sgm.SchoolGradeDivisionMatrixId)) 
   AND sa.AcademicYearId = @AcademicYearId
   AND (@FromDate IS NULL OR sa.AttendanceDateTime BETWEEN @FromDate  AND @TillDate )
   AND (LEN(@SearchText) = 0
   OR CONCAT(g.GradeName, '-', d.DivisionName) LIKE '%' + @SearchText + '%'
   OR LEN(@SearchText)>0 AND(sgdm.RollNumber LIKE '%' + @SearchText + '%')
   OR LEN(@SearchText) > 0 AND (s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName LIKE '%' + @SearchText + '%')
   ) 

    GROUP BY
    sa.AcademicYearId,
    sa.GradeId,
    sa.divisionId,
	g.GradeName,
    d.DivisionName,
    sgdm.RollNumber, 
    CONCAT(s.FirstName,' ',s.MiddleName ,' ' , s.LastName),
    sa.StudentId
	) SELECT COUNT(cnt) as TotalRecords FROM CTE;

  IF(@OrderBy_ASC_DESC='desc')
  BEGIN

  SELECT
  sa.AcademicYearId,
  sa.GradeId,
  sa.DivisionId,
  g.GradeName,
  d.DivisionName,
  sgdm.RollNumber, 
  CONCAT(s.FirstName,' ',s.MiddleName,' ',s.LastName) as 'FullName',
   COUNT(AttendanceDateTime)  AS 'TotalDay',
   COUNT(CASE WHEN sa.StatusId = 1 THEN 1 END) AS 'PresentDay',
   COUNT(CASE WHEN sa.StatusId = 2 THEN 1 END) AS 'HalfDay',
   COUNT(CASE WHEN sa.StatusId = 3 THEN 1 END) AS 'AbsentDay',
   CONCAT(FORMAT(((COUNT(CASE WHEN sa.StatusId = 1 THEN 1 END) + 0.5 * COUNT(CASE WHEN sa.StatusId = 2 THEN 1 END)) / NULLIF(COALESCE(COUNT(sa.AttendanceDateTime), 0), 0)) * 100, '0.00'), '%') AS 'AttendancePercentage'
   
  FROM dbo.[StudentAttendance]  AS sa
  INNER JOIN dbo.[StudentGradeDivisionMapping] As sgdm ON sa.StudentId= sgdm.StudentId
  INNER JOIN dbo.[Student] AS s ON sa.StudentId = s.StudentId 
  INNER JOIN dbo.[Grade] g ON sa.GradeId = g.GradeId
  INNER JOIN dbo.[Division] d ON sa.DivisionId = d.DivisionId
  INNER JOIN dbo.[SchoolGradeDivisionMatrix] sgm ON g.GradeId=sgm.GradeId AND d.DivisionId=sgm.DivisionId

    WHERE
    ISNULL(sa.IsDeleted,0)<>1 AND ISNULL(s.IsDeleted,0)<>1 AND ISNULL(s.IsArchive,0)<>1 AND ISNULL(sgm.IsDeleted,0)<>1 and sgm.AcademicYearId = @AcademicYearId
    AND  (@classIdCount=0 OR EXISTS(SELECT Id FROM @classIds WHERE Id=sgm.SchoolGradeDivisionMatrixId)) 
    AND sa.AcademicYearId = @AcademicYearId
    AND  (@FromDate IS NULL OR sa.AttendanceDateTime BETWEEN @FromDate  AND @TillDate)
    AND (LEN(@SearchText) = 0
    OR CONCAT(g.GradeName, '-', d.DivisionName) LIKE '%' + @SearchText + '%'	
    OR LEN(@SearchText)>0 AND(sgdm.RollNumber LIKE '%' + @SearchText + '%')
    OR LEN(@SearchText) > 0 AND (s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName LIKE '%' + @SearchText + '%')
     ) 

    GROUP BY
    sa.AcademicYearId,
    sa.GradeId,
    sa.divisionId,
    g.GradeName,
    d.DivisionName,
    sgdm.RollNumber, 
    CONCAT(s.FirstName,' ',s.MiddleName,' ',s.LastName),
    sa.StudentId

 ORDER BY
 CASE WHEN @OrderBy = 0 THEN len(g.GradeName + '-'+  d.DivisionName) END DESC, g.GradeName + '-'+  d.DivisionName DESC, CAST(sgdm.RollNumber AS INT) DESC,
 CASE WHEN @OrderBy = 1 THEN CAST(sgdm.RollNumber AS INT) END DESC,
 CASE WHEN @OrderBy = 2 THEN CONCAT(s.FirstName ,' ' ,s.MiddleName , ' ' , s.LastName) END DESC,
 CASE WHEN @OrderBy = 3 THEN COUNT(sa.AttendanceDateTime) END DESC,
 CASE WHEN @OrderBy = 4 THEN COUNT(CASE WHEN sa.StatusId = 1 THEN 1 END) END DESC,
 CASE WHEN @OrderBy = 5 THEN COUNT(CASE WHEN sa.StatusId = 2 THEN 1 END) END DESC,
 CASE WHEN @OrderBy = 6 THEN COUNT(CASE WHEN sa.StatusId = 3 THEN 1 END) END DESC,
 CASE WHEN @OrderBy = 7 THEN CAST(((COUNT(CASE WHEN sa.StatusId = 1 THEN 1 END) + 0.5 * COUNT(CASE WHEN sa.StatusId = 2 THEN 1 END)) / NULLIF(COALESCE(COUNT(sa.AttendanceDateTime), 0), 0)) * 100 AS INT)
 END DESC

  OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY;                               
                                
 END
 ELSE
 BEGIN

  SELECT
  sa.AcademicYearId,
  sa.GradeId,
  sa.DivisionId,
  g.GradeName,
  d.DivisionName,
  sgdm.RollNumber, 
  CONCAT(s.FirstName ,' ' , s.MiddleName , ' ' ,s.LastName) as 'FullName',
   COUNT(AttendanceDateTime)  AS 'TotalDay',
   COUNT(CASE WHEN sa.StatusId = 1 THEN 1 END) AS 'PresentDay',
   COUNT(CASE WHEN sa.StatusId = 2 THEN 1 END) AS 'HalfDay',
   COUNT(CASE WHEN sa.StatusId = 3 THEN 1 END) AS 'AbsentDay',
   CONCAT(FORMAT(((COUNT(CASE WHEN sa.StatusId = 1 THEN 1 END) + 0.5 * COUNT(CASE WHEN sa.StatusId = 2 THEN 1 END)) / NULLIF(COALESCE(COUNT(sa.AttendanceDateTime), 0), 0)) * 100, '0.00'), '%') AS 'AttendancePercentage'
   
  FROM dbo.[StudentAttendance]  AS sa
  INNER JOIN dbo.[StudentGradeDivisionMapping] As sgdm ON sa.StudentId= sgdm.StudentId
  INNER JOIN dbo.[Student] AS s ON sa.StudentId = s.StudentId 
  INNER JOIN dbo.[Grade] g ON sa.GradeId = g.GradeId
  INNER JOIN dbo.[Division] d ON sa.DivisionId = d.DivisionId
  INNER JOIN dbo.[SchoolGradeDivisionMatrix] sgm ON g.GradeId=sgm.GradeId AND d.DivisionId=sgm.DivisionId

    WHERE
    ISNULL(sa.IsDeleted,0)<>1 AND s.IsDeleted <> 1 AND s.IsArchive <> 1 AND ISNULL(sgm.IsDeleted,0)<>1 and sgm.AcademicYearId = @AcademicYearId
    AND(@classIdCount=0 OR  EXISTS (SELECT Id FROM @classIds WHERE Id=sgm.SchoolGradeDivisionMatrixId)) 
    AND sa.AcademicYearId = @AcademicYearId 
	AND  (@FromDate IS NULL OR sa.AttendanceDateTime BETWEEN @FromDate  AND @TillDate )
	AND (LEN(@SearchText) = 0
	OR CONCAT(g.GradeName, '-', d.DivisionName) LIKE '%' + @SearchText + '%'
	OR LEN(@SearchText)>0 AND(sgdm.RollNumber LIKE '%' + @SearchText + '%')
    OR LEN(@SearchText) > 0 AND (s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName LIKE '%' + @SearchText + '%')
     ) 
	
    GROUP BY
    sa.AcademicYearId,
    sa.GradeId,
    sa.divisionId,
    g.GradeName,
    d.DivisionName,
    sgdm.RollNumber, 
    CONCAT(s.FirstName ,' ' ,s.MiddleName , ' ' , s.LastName),
    sa.StudentId

  
    ORDER BY
    CASE WHEN @OrderBy = 0 THEN len(g.GradeName + '-'+  d.DivisionName) END ASC, g.GradeName + '-'+  d.DivisionName ASC, CAST(sgdm.RollNumber AS INT) ASC,
    CASE WHEN @OrderBy = 1 THEN CAST(sgdm.RollNumber AS INT) END ASC,
    CASE WHEN @OrderBy = 2 THEN CONCAT(s.FirstName ,' ' ,s.MiddleName , ' ' , s.LastName) END ASC,
    CASE WHEN @OrderBy = 3 THEN COUNT(sa.AttendanceDateTime) END ASC,
    CASE WHEN @OrderBy = 4 THEN COUNT(CASE WHEN sa.StatusId = 1 THEN 1 END) END ASC,
	CASE WHEN @OrderBy = 5 THEN COUNT(CASE WHEN sa.StatusId = 2 THEN 1 END) END ASC,
	CASE WHEN @OrderBy = 6 THEN COUNT(CASE WHEN sa.StatusId = 3 THEN 1 END) END ASC,
    CASE WHEN @OrderBy = 7 THEN CAST(((COUNT(CASE WHEN sa.StatusId = 1 THEN 1 END) + 0.5 * COUNT(CASE WHEN sa.StatusId = 2 THEN 1 END)) / NULLIF(COALESCE(COUNT(sa.AttendanceDateTime), 0), 0)) * 100 AS INT)
    END ASC
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

