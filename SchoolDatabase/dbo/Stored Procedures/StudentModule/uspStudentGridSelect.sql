-- =============================================
-- Author:    Deepak Walunj
-- Create date: 10/08/2023
-- Description:  This stored procedure is used to get Student info
-- =============================================
CREATE PROC [dbo].[uspStudentGridSelect](@RequestModel NVARCHAR(MAX)
) AS Begin
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

  SELECT COUNT(s.StudentId)
  FROM Student s INNER JOIN StudentGradeDivisionMapping m ON s.StudentId=m.StudentId
  INNER JOIN Grade g ON m.GradeId = g.GradeId
  INNER JOIN Division d ON m.DivisionId = d.DivisionId
  WHERE
    ISNULL(s.IsDeleted,0)<>1 AND ISNULL(m.IsDeleted,0)<>1 AND s.IsArchive <> 1
	AND m.AcademicYearId = @AcademicYearId
	AND (m.GradeId=ISNULL(@GradeId,m.GradeId) OR m.GradeId=@GradeId)  
	AND (m.DivisionId=ISNULL(@DivisionId,m.DivisionId) OR m.DivisionId=@DivisionId)
  AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (s.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (s.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (m.RollNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.GeneralRegistrationNo LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.AdharNo LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (g.GradeName + ' - ' + d.DivisionName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (S.AppAccessMobileNo LIKE '%'+@SearchText+'%')
  ));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT m.RollNumber
  , s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName as 'FullName'
  , s.GeneralRegistrationNo
  , s.AdharNo
  , g.GradeName + ' - ' + d.DivisionName AS GradeName
  , s.StudentId
  , s.AppAccessMobileNo
  , s.EmergencyContactNumber
  , (SELECT TOP 1 fm.ParentId FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = s.StudentId AND fp.ParentTypeId = 11 and fp.IsDeleted <> 1) AS 'FatherId'
  , (SELECT TOP 1 fm.ParentId FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = s.StudentId AND fp.ParentTypeId = 12 and fp.IsDeleted <> 1) AS 'MotherId'
  , (SELECT TOP 1 fm.ParentId FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = s.StudentId AND fp.ParentTypeId = 13 and fp.IsDeleted <> 1) AS 'GuardianId'
  FROM Student s INNER JOIN StudentGradeDivisionMapping m ON s.StudentId=m.StudentId
  INNER JOIN Grade g ON m.GradeId = g.GradeId
  INNER JOIN Division d ON m.DivisionId = d.DivisionId
  WHERE
    ISNULL(s.IsDeleted,0)<>1 AND ISNULL(m.IsDeleted,0)<>1 AND s.IsArchive <> 1
	AND (m.GradeId=ISNULL(@GradeId,m.GradeId) OR m.GradeId=@GradeId)  
	AND (m.DivisionId=ISNULL(@DivisionId,m.DivisionId) OR m.DivisionId=@DivisionId)
	AND m.AcademicYearId = @AcademicYearId 
  AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (s.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (s.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (m.RollNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.GeneralRegistrationNo LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.AdharNo LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (g.GradeName + ' - ' + d.DivisionName  LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (S.AppAccessMobileNo LIKE '%'+@SearchText+'%')

  ))
ORDER BY
--CASE  WHEN @OrderBy=0 THEN m.RollNumber END  DESC,
CASE  WHEN @OrderBy=1 THEN s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName END DESC,
  CASE  WHEN @OrderBy=2 THEN s.GeneralRegistrationNo END DESC,
  CASE  WHEN @OrderBy=3 THEN s.AdharNo END DESC,
  CASE  WHEN @OrderBy=4 THEN len(g.GradeName + ' - ' + d.DivisionName) END DESC, g.GradeName + ' - ' + d.DivisionName DESC,Cast(m.RollNumber as int) DESC,
    CASE  WHEN @OrderBy=5 THEN s.AppAccessMobileNo END DESC

OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                  
                              
                                
 END
 ELSE
 BEGIN
                           
         
 SELECT m.RollNumber
  , s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName as 'FullName'
  , s.GeneralRegistrationNo
  , s.AdharNo
  , g.GradeName + ' - ' + d.DivisionName AS GradeName
  , s.StudentId
  , s.AppAccessMobileNo
  , s.EmergencyContactNumber
  , (SELECT TOP 1 fm.ParentId FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = s.StudentId AND fp.ParentTypeId = 11 and fp.IsDeleted <> 1) AS 'FatherId'
  , (SELECT TOP 1 fm.ParentId FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = s.StudentId AND fp.ParentTypeId = 12 and fp.IsDeleted <> 1) AS 'MotherId'
  , (SELECT TOP 1 fm.ParentId FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = s.StudentId AND fp.ParentTypeId = 13 and fp.IsDeleted <> 1) AS 'GuardianId'
  FROM Student s INNER JOIN StudentGradeDivisionMapping m ON s.StudentId=m.StudentId
  INNER JOIN Grade g ON m.GradeId = g.GradeId
  INNER JOIN Division d ON m.DivisionId = d.DivisionId
  WHERE
    ISNULL(s.IsDeleted,0)<>1 AND ISNULL(m.IsDeleted,0)<>1  AND s.IsArchive <> 1
	AND (m.GradeId=ISNULL(@GradeId,m.GradeId) OR m.GradeId=@GradeId)  
	AND (m.DivisionId=ISNULL(@DivisionId,m.DivisionId) OR m.DivisionId=@DivisionId)
	AND m.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 OR
  LEN(@SearchText)>0 AND  (s.FirstName LIKE +@SearchText+'%'
  OR  LEN(@SearchText)>0 AND (s.MiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.LastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (m.RollNumber LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.GeneralRegistrationNo LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.AdharNo LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (g.GradeName + ' - ' + d.DivisionName  LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (S.AppAccessMobileNo LIKE '%'+@SearchText+'%')

  ))
ORDER BY
CASE  WHEN @OrderBy=0 THEN m.RollNumber END  ASC,
CASE  WHEN @OrderBy=1 THEN s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName END ASC,
  CASE  WHEN @OrderBy=2 THEN s.GeneralRegistrationNo END ASC,
  CASE  WHEN @OrderBy=3 THEN s.AdharNo END ASC,
  CASE  WHEN @OrderBy=4 THEN len(g.GradeName + ' - ' + d.DivisionName) END ASC, g.GradeName + ' - ' + d.DivisionName ASC, Cast(m.RollNumber as int) ASC,
  CASE  WHEN @OrderBy=5 THEN s.AppAccessMobileNo END ASC

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