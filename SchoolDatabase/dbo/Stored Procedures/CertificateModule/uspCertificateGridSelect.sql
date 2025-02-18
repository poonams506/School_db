-- =============================================
-- Author:    Meena Kotkar
-- Create date: 229/08/2023
-- Description:  This stored procedure is used to get Student info
-- =============================================
CREATE PROC uspCertificateGridSelect(@RequestModel NVARCHAR(MAX)) AS BEGIN
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

 
  SELECT COUNT(c.CertificateAuditsId)
  FROM CertificateAudits c 
  INNER JOIN StudentGradeDivisionMapping m ON c.StudentId=m.StudentId
  INNER JOIN Grade g ON m.GradeId = g.GradeId
  INNER JOIN Division d ON m.DivisionId = d.DivisionId
  INNER JOIN Student s ON m.StudentId=s.StudentId

  WHERE
      ISNULL(c.IsDeleted,0)<>1 AND ISNULL(m.IsDeleted,0)<>1  AND s.IsArchive <> 1 AND s.IsDeleted <> 1 AND c.AcademicYearId = @AcademicYearId
      AND m.AcademicYearId = @AcademicYearId
      AND (LEN(@SearchText)=0 OR
      LEN(@SearchText)>0 AND  (s.FirstName LIKE +@SearchText+'%'
      OR  LEN(@SearchText)>0 AND (s.MiddleName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (s.LastName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (g.GradeName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (d.DivisionName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (c.Remark LIKE '%'+@SearchText+'%')
      --OR (@SearchText='Bonafide' AND TypeId = 1)                 
      --OR (@SearchText='ID Card' AND  TypeId= 2)                    
      --OR (@SearchText='Character' AND TypeId= 3)
      --OR (@SearchText='Living' AND  TypeId= 4)
      OR LEN(@SearchText)>0 AND (IIF(c.IsPublished = 1,'Y','N') LIKE '%'+@SearchText+'%')
      ));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
  SELECT 
       c.StudentId,
       c.CertificateAuditsId,
       s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName AS 'FullName',
       g.GradeName,
       d.DivisionName,
       CASE WHEN c.IsPublished = 1 THEN 'Y'
          WHEN c.IsPublished = 0 THEN 'N'
          END AS 'Status'
   FROM CertificateAudits c 
      INNER JOIN StudentGradeDivisionMapping m ON c.StudentId=m.StudentId
      INNER JOIN Grade g ON m.GradeId = g.GradeId
      INNER JOIN Division d ON m.DivisionId = d.DivisionId
      INNER JOIN Student s ON m.StudentId=s.StudentId
  WHERE
      ISNULL(s.IsDeleted,0)<>1 AND ISNULL(m.IsDeleted,0)<>1  AND s.IsArchive <> 1 AND s.IsDeleted <> 1 AND c.AcademicYearId = @AcademicYearId
      AND m.AcademicYearId = @AcademicYearId 
      AND (LEN(@SearchText)=0 OR
      LEN(@SearchText)>0 AND  (s.FirstName LIKE +@SearchText+'%'
      OR  LEN(@SearchText)>0 AND (s.MiddleName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (s.LastName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (g.GradeName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (d.DivisionName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (c.Remark LIKE '%'+@SearchText+'%')
      --OR (@SearchText='Bonafide' AND TypeId = 1)                 
      --OR (@SearchText='ID Card' AND  TypeId= 2)                    
      --OR (@SearchText='Character' AND TypeId= 3)
      --OR (@SearchText='Living' AND  TypeId= 4)
      OR LEN(@SearchText)>0 AND (IIF(c.IsPublished = 1,'Y','N') LIKE '%'+@SearchText+'%')
      ))
ORDER BY
    CASE  WHEN @OrderBy=0 THEN s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName END DESC,
    CASE  WHEN @OrderBy=1 THEN g.GradeName END DESC,
    CASE  WHEN @OrderBy=2 THEN d.DivisionName END DESC,
    --CASE  WHEN @OrderBy=3 THEN c.TypeName  END  DESC,
    CASE  WHEN @OrderBy=4 THEN c.Remark  END  DESC,
    CASE  WHEN @OrderBy=5 THEN c.IsPublished  END  DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
  
 END
 ELSE
 BEGIN       
    SELECT 
        c.StudentId,
        c.CertificateAuditsId,
        s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName AS 'FullName',
        g.GradeName,
        d.DivisionName,
        CASE WHEN c.IsPublished = 1 THEN 'Y'
          WHEN c.IsPublished = 0 THEN 'N'
          END AS 'Status'
   FROM CertificateAudits c 
      INNER JOIN StudentGradeDivisionMapping m ON c.StudentId=m.StudentId
      INNER JOIN Grade g ON m.GradeId = g.GradeId
      INNER JOIN Division d ON m.DivisionId = d.DivisionId
      INNER JOIN Student s ON m.StudentId=s.StudentId

  WHERE
      ISNULL(s.IsDeleted,0)<>1 AND ISNULL(m.IsDeleted,0)<>1 AND m.AcademicYearId = @AcademicYearId   AND s.IsArchive <> 1 AND s.IsDeleted <> 1 AND c.AcademicYearId = @AcademicYearId
      AND (LEN(@SearchText)=0 
      OR  LEN(@SearchText)>0 AND  (s.FirstName LIKE +@SearchText+'%'
      OR  LEN(@SearchText)>0 AND (s.MiddleName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (s.LastName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (g.GradeName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (d.DivisionName LIKE '%'+@SearchText+'%')
      OR  LEN(@SearchText)>0 AND (c.Remark LIKE '%'+@SearchText+'%')
      --OR (@SearchText='Bonafide' AND TypeId = 1)                 
      --OR (@SearchText='ID Card' AND  TypeId= 2)                    
      --OR (@SearchText='Character' AND TypeId= 3)
      --OR (@SearchText='Living' AND  TypeId= 4)
      OR LEN(@SearchText)>0 AND (IIF(c.IsPublished = 1,'Y','N') LIKE '%'+@SearchText+'%')
      ))
ORDER BY
    CASE  WHEN @OrderBy=0 THEN s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName END ASC,
    CASE  WHEN @OrderBy=1 THEN g.GradeName END ASC,
    CASE  WHEN @OrderBy=2 THEN d.DivisionName END ASC,
    --CASE  WHEN @OrderBy=3 THEN c.TypeName  END  ASC,
    CASE  WHEN @OrderBy=4 THEN c.Remark  END  ASC,
    CASE  WHEN @OrderBy=5 THEN c.IsPublished  END  ASC

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