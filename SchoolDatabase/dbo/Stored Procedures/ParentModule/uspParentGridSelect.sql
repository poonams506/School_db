-- =============================================
-- Author:    Deepak Walunj
-- Create date: 13/08/2023
-- Description:  This stored procedure is used to get parent info
-- =============================================
CREATE PROC [dbo].[uspParentGridSelect](@RequestModel NVARCHAR(MAX)) AS Begin
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
  DECLARE @GradeId SMALLINT=JSON_VALUE(@RequestModel, '$.gradeId');
 DECLARE @DivisionId SMALLINT=JSON_VALUE(@RequestModel, '$.divisionId');
 
  SELECT COUNT(p.ParentId)
  FROM Parent p
  LEFT JOIN ParentStudentMapping pm ON p.ParentId = pm.ParentId
  LEFT JOIN Student s ON pm.StudentId = s.StudentId
  INNER JOIN StudentGradeDivisionMapping m ON pm.StudentId=m.StudentId
  INNER JOIN Grade g ON m.GradeId = g.GradeId
  INNER JOIN Division d ON m.DivisionId = d.DivisionId
  WHERE
    ISNULL(s.IsDeleted,0)<>1 AND ISNULL(p.IsDeleted,0)<>1 AND s.IsArchive <> 1 AND m.IsDeleted <> 1
	AND m.AcademicYearId = @AcademicYearId
	AND (m.GradeId=ISNULL(@GradeId,m.GradeId) OR m.GradeId=@GradeId)  
	AND (m.DivisionId=ISNULL(@DivisionId,m.DivisionId) OR m.DivisionId=@DivisionId)
  AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (s.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (s.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.FirstName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.LastName LIKE '%'+@SearchText+'%')
  OR (@SearchText='Father' AND  p.ParentTypeId = 11)                 
  OR (@SearchText='Mother' AND  p.ParentTypeId = 12)                    
  OR (@SearchText='Guardian' AND  p.ParentTypeId = 13)
  OR  LEN(@SearchText)>0 AND (p.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.Zipcode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.EmailId LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.DistrictName LIKE '%'+@SearchText+'%')
  ));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT 
    p.ParentId,
  s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName as 'StudentFullName'
  , concat(p.FirstName , ' ' , p.MiddleName , ' ' , p.LastName) as 'ParentFullName'
  , CASE  WHEN p.ParentTypeId=11 THEN 'Father'
          WHEN p.ParentTypeId=12 THEN 'Mother'
          WHEN p.ParentTypeId=13 THEN 'Guardian' END AS 'ParentType'
  , p.MobileNumber
  , ISNULL(p.AddressLine1,'') + IIF(p.AddressLine1 IS NULL,'',', ') + ISNULL(p.AddressLine2,'') + IIF(p.AddressLine2 IS NULL,'',', ') + p.TalukaName + ', ' + p.DistrictName + IIF(p.Zipcode IS NULL,'',', ' + p.Zipcode) AS 'Address'
  ,p.EmailId
  FROM Parent p
  LEFT JOIN ParentStudentMapping pm ON p.ParentId = pm.ParentId
  LEFT JOIN Student s ON pm.StudentId = s.StudentId
  INNER JOIN StudentGradeDivisionMapping m ON pm.StudentId=m.StudentId
  INNER JOIN Grade g ON m.GradeId = g.GradeId
  INNER JOIN Division d ON m.DivisionId = d.DivisionId
  WHERE
     ISNULL(s.IsDeleted,0)<>1 AND ISNULL(p.IsDeleted,0)<>1  AND s.IsArchive <> 1 AND m.IsDeleted <> 1
	 AND m.AcademicYearId = @AcademicYearId
	 AND (m.GradeId=ISNULL(@GradeId,m.GradeId) OR m.GradeId=@GradeId)  
	AND (m.DivisionId=ISNULL(@DivisionId,m.DivisionId) OR m.DivisionId=@DivisionId)
  AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (s.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (s.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.FirstName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.LastName LIKE '%'+@SearchText+'%')
  OR (@SearchText='Father' AND  p.ParentTypeId = 11)                 
  OR (@SearchText='Mother' AND  p.ParentTypeId = 12)                    
  OR (@SearchText='Guardian' AND  p.ParentTypeId = 13)
  OR  LEN(@SearchText)>0 AND (p.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.Zipcode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.EmailId LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.DistrictName LIKE '%'+@SearchText+'%')
  ))
ORDER BY
CASE  WHEN @OrderBy=0 THEN s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName END DESC,
CASE  WHEN @OrderBy=1 THEN concat(p.FirstName , ' ' , p.MiddleName , ' ' , p.LastName)  END  DESC,
  CASE  WHEN @OrderBy=2 AND p.ParentTypeId = 11 THEN 'Father' END DESC,
  CASE  WHEN @OrderBy=2 AND p.ParentTypeId = 12 THEN 'Mother' END DESC,
  CASE  WHEN @OrderBy=2 AND p.ParentTypeId = 13 THEN 'Guardian' END DESC,
  CASE  WHEN @OrderBy=3 THEN   ISNULL(p.AddressLine1,'') + IIF(p.AddressLine1 IS NULL,'',', ') + ISNULL(p.AddressLine2,'') + IIF(p.AddressLine2 IS NULL,'',', ') + p.TalukaName + ', ' + p.DistrictName + IIF(p.Zipcode IS NULL,'',', ' + p.Zipcode) END DESC,
   CASE  WHEN @OrderBy=4 THEN p.MobileNumber END DESC,
  CASE  WHEN @OrderBy=5 THEN p.EmailId END DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                  
                              
                                
 END
 ELSE
 BEGIN
                           
         
 SELECT 
  p.ParentId,
  s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName as 'StudentFullName'
  , concat(p.FirstName , ' ' , p.MiddleName , ' ' , p.LastName) as 'ParentFullName'
  , CASE  WHEN p.ParentTypeId=11 THEN 'Father'
          WHEN p.ParentTypeId=12 THEN 'Mother'
          WHEN p.ParentTypeId=13 THEN 'Guardian' END AS 'ParentType'
  , p.MobileNumber
   , ISNULL(p.AddressLine1,'') + IIF(p.AddressLine1 IS NULL,'',', ') + ISNULL(p.AddressLine2,'') + IIF(p.AddressLine2 IS NULL,'',', ') + p.TalukaName + ', ' + p.DistrictName + IIF(p.Zipcode IS NULL,'',', ' + p.Zipcode) AS 'Address'
  ,p.EmailId
  FROM Parent p
  LEFT JOIN ParentStudentMapping pm ON p.ParentId = pm.ParentId
  LEFT JOIN Student s ON pm.StudentId = s.StudentId
  INNER JOIN StudentGradeDivisionMapping m ON pm.StudentId=m.StudentId
  INNER JOIN Grade g ON m.GradeId = g.GradeId
  INNER JOIN Division d ON m.DivisionId = d.DivisionId
  WHERE
     ISNULL(s.IsDeleted,0)<>1 AND ISNULL(p.IsDeleted,0)<>1  AND s.IsArchive <> 1 AND m.IsDeleted <> 1
	 AND m.AcademicYearId = @AcademicYearId
	 AND (m.GradeId=ISNULL(@GradeId,m.GradeId) OR m.GradeId=@GradeId)  
	AND (m.DivisionId=ISNULL(@DivisionId,m.DivisionId) OR m.DivisionId=@DivisionId)
  AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (s.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (s.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.FirstName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.LastName LIKE '%'+@SearchText+'%')
  OR (@SearchText='Father' AND  p.ParentTypeId = 11)                 
  OR (@SearchText='Mother' AND  p.ParentTypeId = 12)                    
  OR (@SearchText='Guardian' AND  p.ParentTypeId = 13)
  OR  LEN(@SearchText)>0 AND (p.MobileNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.AddressLine1 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.AddressLine2 LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.Zipcode LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.EmailId LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.TalukaName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (p.DistrictName LIKE '%'+@SearchText+'%')
  ))
ORDER BY
CASE  WHEN @OrderBy=0 THEN s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName END ASC,
CASE  WHEN @OrderBy=1 THEN concat(p.FirstName , ' ' , p.MiddleName , ' ' , p.LastName)  END  ASC,
  CASE  WHEN @OrderBy=2 AND p.ParentTypeId = 11 THEN 'Father' END ASC,
  CASE  WHEN @OrderBy=2 AND p.ParentTypeId = 12 THEN 'Mother' END ASC,
  CASE  WHEN @OrderBy=2 AND p.ParentTypeId = 13 THEN 'Guardian' END ASC,
  CASE  WHEN @OrderBy=3 THEN  ISNULL(p.AddressLine1,'') + IIF(p.AddressLine1 IS NULL,'',', ') + ISNULL(p.AddressLine2,'') + IIF(p.AddressLine2 IS NULL,'',', ') + p.TalukaName + ', ' + p.DistrictName + IIF(p.Zipcode IS NULL,'',', ' + p.Zipcode) END ASC,
     CASE  WHEN @OrderBy=4 THEN p.MobileNumber END ASC,
 CASE  WHEN @OrderBy=5 THEN p.EmailId END ASC
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