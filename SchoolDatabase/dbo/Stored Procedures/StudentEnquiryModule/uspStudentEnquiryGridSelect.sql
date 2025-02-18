--===============================================
-- Author:- Gulave Pramod
-- Create date:- 06-08-2024
-- Description:- This stored procedure is used to get StudentEnquiryForm by GridSelect.
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentEnquiryGridSelect](@RequestModel NVARCHAR(MAX)) AS Begin
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

  DECLARE  @studentEnquiryTemp TABLE(
 StudentEnquiryId int
 ) 
 INSERT INTO @studentEnquiryTemp
 SELECT DISTINCT S.StudentEnquiryId
  FROM StudentEnquiry S
       
 
  SELECT COUNT(s.StudentEnquiryId)
  FROM StudentEnquiry as s
    LEFT JOIN SchoolGradeDivisionMatrix AS sgm ON s.InterestedClassId = sgm.SchoolGradeDivisionMatrixId
	LEFT JOIN Grade AS g ON sgm.GradeId = g.GradeId
    LEFT JOIN Division AS d ON sgm.DivisionId = d.DivisionId

  WHERE
    ISNULL(s.IsDeleted,0)<>1  AND sgm.IsDeleted<>1
	AND s.AcademicYearId = @AcademicYearId AND sgm.AcademicYearId=@AcademicYearId
	AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND (s.EnquiryDate LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.StudentFirstName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.StudentMiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.StudentLastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (g.GradeName + ' - ' + d.DivisionName  LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.FatherFirstName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.FatherMiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.FatherLastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.AdharNo LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.MobileNumber LIKE '%'+@SearchText+'%')
 )

 
   DECLARE  @temp3 TABLE(

 PaidAmount MONEY,
 PaymentStatus NVARCHAR(20),
 AcademicYearId INT,
 StudentEnquiryId INT
 )
  INSERT INTO @temp3
  SELECT 
     dbo.udfRegistrationPaidAmount( S.AcademicYearId, S.StudentEnquiryId) AS 'PaidAmount',
	 CASE 
        WHEN dbo.udfRegistrationFeeStatus(S.AcademicYearId, S.StudentEnquiryId) > 0 THEN 'Completed'
        ELSE 'Pending'
    END AS 'PaymentStatus',
	 S.AcademicYearId, S.StudentEnquiryId
  FROM StudentEnquiry S
  INNER JOIN @studentEnquiryTemp t ON
	   S.StudentEnquiryId = t.StudentEnquiryId
	   
  WHERE
    ISNULL(s.IsDeleted,0)<>1  
	AND s.AcademicYearId = @AcademicYearId

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
 SELECT 
    s.StudentEnquiryId,
    s.AcademicYearId,
	s.EnquiryDate,
	CONCAT(s.StudentFirstName ,' ' , s.StudentMiddleName , ' ', s.StudentLastName) as 'StudentFullName',
	CONCAT(s.FatherFirstName , ' ' , s.FatherMiddleName , ' ' , s.FatherLastName) as 'FatherFullName',
	s.AdharNo,
	s.InterestedClassId,
    CONCAT(g.GradeName, ' - ', d.DivisionName) AS ClassName,
	s.MobileNumber,
	temp.PaidAmount AS 'PaidAmount',
	temp.PaymentStatus AS 'PaymentStatus'
  FROM
	StudentEnquiry AS s
	LEFT JOIN SchoolGradeDivisionMatrix AS sgm ON s.InterestedClassId = sgm.SchoolGradeDivisionMatrixId
	LEFT JOIN Grade AS g ON sgm.GradeId = g.GradeId
    LEFT JOIN Division AS d ON sgm.DivisionId = d.DivisionId
	INNER JOIN @temp3 temp ON
	 s.AcademicYearId = temp.AcademicYearId AND s.StudentEnquiryId = temp.StudentEnquiryId
	    INNER JOIN @studentEnquiryTemp t ON
	   S.StudentEnquiryId = t.StudentEnquiryId

  WHERE
     ISNULL(s.IsDeleted,0)<>1  AND sgm.IsDeleted<>1
	 AND s.AcademicYearId = @AcademicYearId AND sgm.AcademicYearId=@AcademicYearId
	 AND(LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND (s.EnquiryDate LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.StudentFirstName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.StudentMiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.StudentLastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.FatherFirstName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.FatherMiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.FatherLastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (g.GradeName + ' - ' + d.DivisionName  LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.AdharNo LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.MobileNumber LIKE '%'+@SearchText+'%')
 OR  LEN(@SearchText)>0 AND (temp.PaidAmount LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (temp.PaymentStatus LIKE '%'+@SearchText+'%')
 )
ORDER BY
CASE  WHEN @OrderBy=0 THEN s.EnquiryDate END DESC,
  CASE  WHEN @OrderBy=1 THEN  CONCAT(s.StudentFirstName ,' ' , s.StudentMiddleName , ' ', s.StudentLastName) END DESC,
  CASE  WHEN @OrderBy=2 THEN CONCAT(s.FatherFirstName , ' ' , s.FatherMiddleName , ' ' , s.FatherLastName) END DESC,
  CASE  WHEN @OrderBy=3 THEN s.AdharNo END DESC,
  CASE  WHEN @OrderBy=5 THEN s.MobileNumber END DESC,
  CASE  WHEN @OrderBy=6 THEN temp.PaidAmount END DESC,
  CASE  WHEN @OrderBy=7 THEN temp.PaymentStatus END DESC,
  CASE  WHEN @OrderBy=4 THEN len(g.GradeName + ' - ' + d.DivisionName) END DESC, g.GradeName + ' - ' + d.DivisionName DESC
OFFSET @PageNumber ROWS
  FETCH NEXT @PageSize ROWS ONLY
                                                             
 END
 ELSE
 BEGIN        
 SELECT 
    s.StudentEnquiryId,
    s.AcademicYearId,
	s.EnquiryDate,
	CONCAT(s.StudentFirstName ,' ' , s.StudentMiddleName , ' ', s.StudentLastName) as 'StudentFullName',
	CONCAT(s.FatherFirstName , ' ' , s.FatherMiddleName , ' ' , s.FatherLastName) as 'FatherFullName',
	s.AdharNo,
	s.InterestedClassId,
	CONCAT(g.GradeName, ' - ', d.DivisionName) AS ClassName,
	s.MobileNumber,
	temp.PaidAmount AS 'PaidAmount',
	temp.PaymentStatus AS 'PaymentStatus'
  FROM
	StudentEnquiry AS s
    LEFT JOIN SchoolGradeDivisionMatrix AS sgm ON s.InterestedClassId = sgm.SchoolGradeDivisionMatrixId
	LEFT JOIN Grade AS g ON sgm.GradeId = g.GradeId
    LEFT JOIN Division AS d ON sgm.DivisionId = d.DivisionId
	INNER JOIN @temp3 temp ON
	 s.AcademicYearId = temp.AcademicYearId AND s.StudentEnquiryId = temp.StudentEnquiryId
	    INNER JOIN @studentEnquiryTemp t ON
	   S.StudentEnquiryId = t.StudentEnquiryId
  WHERE
     ISNULL(s.IsDeleted,0)<>1  AND sgm.IsDeleted<>1
	 AND s.AcademicYearId = @AcademicYearId AND sgm.AcademicYearId=@AcademicYearId 
	 AND (LEN(@SearchText)=0 
  OR  LEN(@SearchText)>0 AND (s.EnquiryDate LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.StudentFirstName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.StudentMiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.StudentLastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.FatherFirstName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.FatherMiddleName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.FatherLastName LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (g.GradeName + ' - ' + d.DivisionName  LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.AdharNo LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (s.MobileNumber LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (temp.PaidAmount LIKE '%'+@SearchText+'%')
  OR  LEN(@SearchText)>0 AND (temp.PaymentStatus LIKE '%'+@SearchText+'%')
 )
ORDER BY
CASE  WHEN @OrderBy=0 THEN s.EnquiryDate END ASC ,
  CASE  WHEN @OrderBy=1 THEN  CONCAT(s.StudentFirstName ,' ' , s.StudentMiddleName , ' ', s.StudentLastName) END ASC,
  CASE  WHEN @OrderBy=2 THEN CONCAT(s.FatherFirstName , ' ' , s.FatherMiddleName , ' ' , s.FatherLastName) END ASC,
  CASE  WHEN @OrderBy=3 THEN s.AdharNo END ASC,
  CASE  WHEN @OrderBy=5 THEN s.MobileNumber END ASC,
   CASE  WHEN @OrderBy=6 THEN temp.PaidAmount END ASC,
    CASE  WHEN @OrderBy=7 THEN temp.PaymentStatus END ASC,
  CASE  WHEN @OrderBy=4 THEN len(g.GradeName + ' - ' + d.DivisionName) END ASC, g.GradeName + ' - ' + d.DivisionName ASC
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