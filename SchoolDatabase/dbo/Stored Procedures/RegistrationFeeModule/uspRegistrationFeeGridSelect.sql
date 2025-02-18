-- =============================================
-- Author:    Prerana Aher
-- Create date: 12/08/2024
-- Description:  This stored procedure is used to get Registration Fee deatils for grid
-- =============================================
CREATE  PROCEDURE [dbo].[uspRegistrationFeeGridSelect]
	@RequestModel NVARCHAR(MAX)
AS
BEGIN
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY
 DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
 DECLARE @IsChequeCleared SMALLINT = JSON_VALUE(@RequestModel, '$.isChequeCleared');
 DECLARE @PageSize INT=JSON_VALUE(@RequestModel, '$.getListModel.length');
 DECLARE @PageNumber INT=JSON_VALUE(@RequestModel, '$.getListModel.start');
 DECLARE @SearchText NVARCHAR(150)=JSON_VALUE(@RequestModel, '$.getListModel.search.value');
 DECLARE @OrderBy INT=JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
 DECLARE @OrderBy_ASC_DESC NVARCHAR(20)=JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');

 DECLARE  @studentTemp TABLE(
 StudentEnquiryId int
 )
 INSERT INTO @studentTemp
 SELECT DISTINCT s.StudentEnquiryId
 FROM StudentEnquiry s
 
 SELECT COUNT(s.StudentEnquiryId)
 FROM StudentEnquiry s
	INNER JOIN @studentTemp t ON
	s.StudentEnquiryId = t.StudentEnquiryId
	INNER JOIN SchoolGradeDivisionMatrix AS sgdm ON sgdm.SchoolGradeDivisionMatrixId = s.InterestedClassId 
	INNER JOIN Grade AS g ON g.GradeId = sgdm.GradeId
	INNER JOIN Division AS d ON d.DivisionId = sgdm.DivisionId
 WHERE
    s.IsDeleted <> 1
    AND (LEN(@SearchText)=0
    OR  LEN(@SearchText)>0 AND (s.EnquiryDate LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (CONCAT(s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName)  LIKE '%'+@SearchText+'%'
    OR  LEN(@SearchText)>0 AND (s.StudentFirstName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (s.StudentMiddleName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (s.StudentLastName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (CONCAT(g.GradeName, '-' , d.DivisionName) LIKE '%'+@SearchText+'%')
    ));

 IF(@OrderBy_ASC_DESC='desc')
 BEGIN
 
 IF @OrderBy=0
 BEGIN
 SELECT 
	s.StudentEnquiryId,
	s.EnquiryDate,
    s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName AS 'StudentFullName',
    g.GradeName, '-' , d.DivisionName AS InterestedClass
 FROM StudentEnquiry s
	INNER JOIN @studentTemp t ON
	s.StudentEnquiryId = t.StudentEnquiryId
	INNER JOIN SchoolGradeDivisionMatrix AS sgdm ON sgdm.SchoolGradeDivisionMatrixId = s.InterestedClassId 
	INNER JOIN Grade AS g ON g.GradeId = sgdm.GradeId
	INNER JOIN Division AS d ON d.DivisionId = sgdm.DivisionId
 WHERE
    s.IsDeleted <> 1
    AND (LEN(@SearchText)=0 
    OR  LEN(@SearchText)>0 AND (s.EnquiryDate LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (CONCAT(s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName)  LIKE '%'+@SearchText+'%'
    OR  LEN(@SearchText)>0 AND (s.StudentFirstName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (s.StudentMiddleName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (s.StudentLastName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (CONCAT(g.GradeName, '-' , d.DivisionName) LIKE '%'+@SearchText+'%')
    ))
 ORDER BY
 CASE WHEN @OrderBy=1 THEN CONCAT(s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName) END DESC,
 CASE WHEN @OrderBy=2 THEN CONCAT(g.GradeName, '-' , d.DivisionName) END DESC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
 END
 ELSE
 BEGIN
 SELECT 
	s.StudentEnquiryId,
    s.EnquiryDate,
    s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName AS 'StudentFullName',
    g.GradeName, '-' , d.DivisionName AS InterestedClass
 FROM StudentEnquiry s
	INNER JOIN @studentTemp t ON
	s.StudentEnquiryId = t.StudentEnquiryId
	INNER JOIN SchoolGradeDivisionMatrix AS sgdm ON sgdm.SchoolGradeDivisionMatrixId = s.InterestedClassId 
	INNER JOIN Grade AS g ON g.GradeId = sgdm.GradeId
	INNER JOIN Division AS d ON d.DivisionId = sgdm.DivisionId

 WHERE
    s.IsDeleted <> 1
    AND (LEN(@SearchText)=0
    OR  LEN(@SearchText)>0 AND (s.EnquiryDate LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (CONCAT(s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName)  LIKE '%'+@SearchText+'%'
    OR  LEN(@SearchText)>0 AND (s.StudentFirstName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (s.StudentMiddleName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (s.StudentLastName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND CONCAT(g.GradeName, '-' , d.DivisionName) LIKE '%'+@SearchText+'%')
    )
 ORDER BY
 CASE WHEN @OrderBy=1 THEN CONCAT(s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName) END DESC,
 CASE WHEN @OrderBy=2 THEN CONCAT(g.GradeName, '-' , d.DivisionName) END DESC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
 END
 END
 ELSE
 BEGIN
        
 IF @OrderBy=0 
 BEGIN
 SELECT 
	s.StudentEnquiryId,
    s.EnquiryDate,
    s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName AS 'StudentFullName',
    g.GradeName, '-' , d.DivisionName AS InterestedClass
 FROM StudentEnquiry s
	INNER JOIN @studentTemp t ON
	s.StudentEnquiryId = t.StudentEnquiryId
	INNER JOIN SchoolGradeDivisionMatrix AS sgdm ON sgdm.SchoolGradeDivisionMatrixId = s.InterestedClassId 
	INNER JOIN Grade AS g ON g.GradeId = sgdm.GradeId
	INNER JOIN Division AS d ON d.DivisionId = sgdm.DivisionId

 WHERE
    s.IsDeleted <> 1
    AND (LEN(@SearchText)=0 
    OR  LEN(@SearchText)>0 AND (s.EnquiryDate LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (CONCAT(s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName)  LIKE '%'+@SearchText+'%'
    OR  LEN(@SearchText)>0 AND (s.StudentFirstName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (s.StudentMiddleName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (s.StudentLastName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND CONCAT(g.GradeName, '-' , d.DivisionName) LIKE '%'+@SearchText+'%')
    )
 ORDER BY
 CASE WHEN @OrderBy=1 THEN CONCAT(s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName) END ASC,
 CASE WHEN @OrderBy=2 THEN CONCAT(g.GradeName, '-' , d.DivisionName) END ASC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
 END
 ELSE
 BEGIN
 SELECT 
	s.StudentEnquiryId,
    s.EnquiryDate,
    s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName AS 'StudentFullName',
    g.GradeName, '-' , d.DivisionName AS InterestedClass
 FROM StudentEnquiry s
	INNER JOIN @studentTemp t ON
	s.StudentEnquiryId = t.StudentEnquiryId
	INNER JOIN SchoolGradeDivisionMatrix AS sgdm ON sgdm.SchoolGradeDivisionMatrixId = s.InterestedClassId 
	INNER JOIN Grade AS g ON g.GradeId = sgdm.GradeId
	INNER JOIN Division AS d ON d.DivisionId = sgdm.DivisionId

 WHERE
    s.IsDeleted <> 1
    AND (LEN(@SearchText)=0 
    OR  LEN(@SearchText)>0 AND (s.EnquiryDate LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (CONCAT(s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName)  LIKE '%'+@SearchText+'%'
    OR  LEN(@SearchText)>0 AND (s.StudentFirstName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (s.StudentMiddleName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND (s.StudentLastName LIKE '%'+@SearchText+'%')
    OR  LEN(@SearchText)>0 AND CONCAT(g.GradeName, '-' , d.DivisionName) LIKE '%'+@SearchText+'%')
    )
 ORDER BY
 CASE WHEN @OrderBy=1 THEN CONCAT(s.StudentFirstName , ' ' , s.StudentMiddleName , ' ' , s.StudentLastName) END ASC,
 CASE WHEN @OrderBy=2 THEN CONCAT(g.GradeName, '-' , d.DivisionName) END ASC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
 END
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
 @ErrorState END CATCH
 END