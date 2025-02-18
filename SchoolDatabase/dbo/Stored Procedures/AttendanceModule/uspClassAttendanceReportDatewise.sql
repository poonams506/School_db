-- =============================================
-- Author:    Prathamesh Ghue
-- Create date: 25/01/2024
-- Description:  This stored procedure is used to get StudentAttendance info
-- =============================================
CREATE PROCEDURE uspClassAttendanceReportDatewise
    @RequestModel NVARCHAR(MAX)
AS 
BEGIN
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 SET NOCOUNT ON;
 BEGIN TRY
    DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
    DECLARE @PageSize INT = JSON_VALUE(@RequestModel, '$.getListModel.length');
    DECLARE @PageNumber INT = JSON_VALUE(@RequestModel, '$.getListModel.start');
    DECLARE @SearchText NVARCHAR(150) = JSON_VALUE(@RequestModel, '$.getListModel.search.value');
    DECLARE @OrderBy INT = JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
    DECLARE @OrderBy_ASC_DESC NVARCHAR(20) = JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');
    DECLARE @TakenOn DATETIME = JSON_VALUE(@RequestModel, '$.takenOn');
    DECLARE @SearchDate DATE;  -- Check if the search text is in the format dd/mm/yyyy
  IF ISDATE(@TakenOn) = 1
  BEGIN
    SET @SearchDate = CONVERT(DATE, @TakenOn, 103); -- Assuming the input format is dd/mm/yyyy (103 is British/French format)
  END
  SELECT COUNT(g.GradeId)
  FROM SchoolGradeDivisionMatrix sgm 
    INNER JOIN Grade g ON sgm.GradeId = g.GradeId
    INNER JOIN Division d ON sgm.DivisionId = d.DivisionId
    OUTER APPLY ( SELECT TOP 1 
                sa.StudentAttendanceId,
                u.Fname,
                u.Lname,
                u.Mname,
                sa.CreatedDate AS CreatedDate
     FROM StudentAttendance sa 
     JOIN dbo.[User] u ON sa.CreatedBy = u.UserId 
     WHERE sa.GradeId = g.GradeId 
          AND sa.DivisionId = d.DivisionId AND sa.AcademicYearId = @AcademicYearId AND sa.IsDeleted <> 1
          AND CONVERT(DATE, sa.AttendanceDateTime, 103) = @SearchDate ) sa

  WHERE ISNULL(sgm.IsDeleted, 0) <> 1  AND sgm.AcademicYearId = @AcademicYearId
     AND (
        (@SearchText IS NULL OR @SearchText = '') -- Check if @SearchText is NULL or empty
        OR CONCAT( sa.Fname , ' ' , sa.Mname , ' ' , sa.Lname) LIKE '%' + @SearchText + '%'
        OR CONCAT(g.GradeName, ' - ', d.DivisionName) LIKE '%' + @SearchText + '%'
        OR (sa.StudentAttendanceId IS NULL AND 'Not Taken' LIKE '%' + @SearchText + '%') -- Filter for 'Not Taken'
        OR (sa.StudentAttendanceId IS NOT NULL AND 'Taken' LIKE '%' + @SearchText + '%') -- Filter for 'Taken'
    );
  IF (@OrderBy_ASC_DESC = 'desc')
  BEGIN
    ;WITH CTE AS (
       SELECT  
          g.GradeId,
          g.GradeName,
          d.DivisionId,
          d.DivisionName,
          sa.Fname,
          sa.Mname,
          sa.Lname,
          sa.CreatedDate,
          CASE WHEN sa.StudentAttendanceId IS NULL THEN 'Not Taken' ELSE 'Taken' END AS 'Status'
       FROM  
        SchoolGradeDivisionMatrix sgm 
        INNER JOIN Grade g ON sgm.GradeId = g.GradeId
        INNER JOIN Division d ON sgm.DivisionId = d.DivisionId
        OUTER APPLY ( SELECT TOP 1 
                        sa.StudentAttendanceId,
                        u.Fname,
                        u.Lname,
                        u.Mname,
                        sa.CreatedDate AS CreatedDate
                     FROM StudentAttendance sa 
                     JOIN dbo.[User] u ON sa.CreatedBy = u.UserId 
                     WHERE sa.GradeId = g.GradeId 
                     AND sa.DivisionId = d.DivisionId  AND sa.AcademicYearId = @AcademicYearId AND sa.IsDeleted <> 1
                     AND CONVERT(DATE, sa.AttendanceDateTime, 103) = @SearchDate ) sa
  WHERE ISNULL(sgm.IsDeleted, 0) <> 1 AND sgm.AcademicYearId = @AcademicYearId
    AND (
  (@SearchText IS NULL OR @SearchText = '') 
  OR CONCAT( sa.Fname , ' ' , sa.Mname , ' ' , sa.Lname) LIKE '%' + @SearchText + '%'
  OR CONCAT(g.GradeName, ' - ', d.DivisionName) LIKE '%' + @SearchText + '%'
  OR (sa.StudentAttendanceId IS NULL AND 'Not Taken' LIKE '%' + @SearchText + '%') 
  OR (sa.StudentAttendanceId IS NOT NULL AND 'Taken' LIKE '%' + @SearchText + '%') 
  ))
  SELECT          
	    GradeId,
        GradeName,
        DivisionId,
        DivisionName,
        [Status],
       CONCAT( Fname , ' ' , Mname , ' ' , Lname) AS 'TakenBy',
        CASE WHEN CONCAT( Fname , ' ' , Mname , ' ' , Lname) IS NOT NULL THEN CreatedDate ELSE NULL END AS 'TakenOn' 
    FROM CTE
  ORDER BY
      CASE WHEN @OrderBy = 0 THEN len(CONCAT(GradeName, ' - ', DivisionName)) END DESC, CONCAT(GradeName, ' - ', DivisionName) ASC,
      CASE WHEN @OrderBy = 1 THEN [Status] END DESC,
      CASE WHEN @OrderBy = 2 THEN CONCAT(Fname, ' ', Mname, ' ', Lname) END DESC,
      CASE WHEN @OrderBy = 3 THEN CreatedDate END DESC -- Use CreatedDate directly here
  OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY;
  END
  ELSE
  BEGIN
      ;WITH CTE AS (
           SELECT  
             g.GradeId,
             g.GradeName,
             d.DivisionId,
             d.DivisionName,
             sa.Fname,
             sa.Mname,
             sa.Lname,
             sa.CreatedDate,
             CASE WHEN sa.StudentAttendanceId IS NULL THEN 'Not Taken' ELSE 'Taken' END AS 'Status'
            FROM  
              SchoolGradeDivisionMatrix sgm 
              INNER JOIN Grade g ON sgm.GradeId = g.GradeId
              INNER JOIN Division d ON sgm.DivisionId = d.DivisionId
              OUTER APPLY ( SELECT TOP 1 
                          sa.StudentAttendanceId,
                          u.Fname,
                          u.Lname,
                          u.Mname,
                          sa.CreatedDate AS CreatedDate
                         FROM StudentAttendance sa 
                        JOIN dbo.[User] u ON sa.CreatedBy = u.UserId 
                        WHERE sa.GradeId = g.GradeId 
                            AND sa.DivisionId = d.DivisionId  AND sa.AcademicYearId = @AcademicYearId AND sa.IsDeleted <> 1
                            AND CONVERT(DATE, sa.AttendanceDateTime, 103) = @SearchDate) sa
  WHERE ISNULL(sgm.IsDeleted, 0) <> 1 AND sgm.AcademicYearId = @AcademicYearId
    AND (
        (@SearchText IS NULL OR @SearchText = '') -- Check if @SearchText is NULL or empty
        OR CONCAT( sa.Fname , ' ' , sa.Mname , ' ' , sa.Lname) LIKE '%' + @SearchText + '%'
        OR CONCAT(g.GradeName, ' - ', d.DivisionName) LIKE '%' + @SearchText + '%'
        OR (sa.StudentAttendanceId IS NULL AND 'Not Taken' LIKE '%' + @SearchText + '%') -- Filter for 'Not Taken'
        OR (sa.StudentAttendanceId IS NOT NULL AND 'Taken' LIKE '%' + @SearchText + '%') -- Filter for 'Taken'
    ))
   SELECT 
        GradeId,
        GradeName,
        DivisionId,
        DivisionName,
        [Status],
       CONCAT( Fname , ' ' , Mname , ' ' , Lname) AS 'TakenBy',
        CASE WHEN CONCAT( Fname , ' ' , Mname , ' ' , Lname) IS NOT NULL THEN CreatedDate ELSE NULL END AS 'TakenOn' 
        FROM CTE
   ORDER BY
     CASE WHEN @OrderBy = 0 THEN len(CONCAT(GradeName, ' - ', DivisionName)) END ASC,CONCAT(GradeName, ' - ', DivisionName) ASC,
     CASE WHEN @OrderBy = 1 THEN [Status] END ASC,
     CASE WHEN @OrderBy = 2 THEN CONCAT(Fname, ' ', Mname, ' ', Lname) END ASC,
     CASE WHEN @OrderBy = 3 THEN CreatedDate END ASC -- Use CreatedDate directly here
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY;
 END
 END TRY
  BEGIN CATCH 
     DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
     DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
     DECLARE @ErrorState INT = ERROR_STATE();
     DECLARE @ErrorNumber INT = ERROR_NUMBER();
     DECLARE @ErrorLine INT = ERROR_LINE();
     DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
     EXEC dbo.uspExceptionLogInsert @ErrorLine,
            @ErrorMessage,
            @ErrorNumber,
            @ErrorProcedure,
            @ErrorSeverity,
            @ErrorState;
    END CATCH;
END;
