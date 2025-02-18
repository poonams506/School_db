-- =============================================
-- Author:    Deepa Walunj
-- Create date: 31/08/2023
-- Description:  This stored procedure is used to get Fee payment deatils for grid
-- =============================================
CREATE  PROCEDURE [dbo].[uspAdhocFeePaymentGridSelect]
	@RequestModel NVARCHAR(MAX)
AS
BEGIN
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY
 DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
 DECLARE @GradeId SMALLINT = JSON_VALUE(@RequestModel, '$.gradeId');
 DECLARE @DivisionId SMALLINT = JSON_VALUE(@RequestModel, '$.divisionId');
 DECLARE @IsChequeCleared SMALLINT = JSON_VALUE(@RequestModel, '$.isChequeCleared');
 DECLARE @PageSize INT=JSON_VALUE(@RequestModel, '$.getListModel.length');
 DECLARE @PageNumber INT=JSON_VALUE(@RequestModel, '$.getListModel.start');
 DECLARE @SearchText NVARCHAR(150)=JSON_VALUE(@RequestModel, '$.getListModel.search.value');
 DECLARE @OrderBy INT=JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
 DECLARE @OrderBy_ASC_DESC NVARCHAR(20)=JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');

 DECLARE  @studentTemp TABLE(
 StudentId int
 )

 INSERT INTO @studentTemp
 SELECT DISTINCT S.StudentId
  FROM StudentGradeDivisionMapping M
       INNER JOIN Student S
       ON M.StudentId = S.StudentId
 
 

  SELECT COUNT(S.StudentId)
  FROM StudentGradeDivisionMapping M
       INNER JOIN Student S
       ON M.StudentId = S.StudentId
	   INNER JOIN @studentTemp t ON
	   S.StudentId = t.StudentId
  WHERE
   M.IsDeleted <> 1
   AND S.IsDeleted <> 1
   AND S.IsArchive <> 1
   AND (M.GradeId = ISNULL(@GradeId, M.GradeId) OR M.GradeId = @GradeId)
   AND (M.DivisionId = ISNULL(@DivisionId, M.DivisionId) OR M.DivisionId = @DivisionId)
   AND M.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (S.FirstName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.LastName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.GeneralRegistrationNo LIKE '%'+@SearchText+'%')
   ));

   DECLARE  @temp3 TABLE(
 TotalFee MONEY,
 ChequeClearedAmount MONEY,
 ChequeUnclearAmount MONEY,
 GradeId INT,
 DivisionId INT,
 AcademicYearId INT,
 StudentId INT
 )
 INSERT INTO @temp3
  SELECT 
     dbo.udfStudentAdhocTotalAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'TotalFee',
     dbo.udfStudentAdhocChequeClearedAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'ChequeClearedAmount',
     dbo.udfStudentAdhocChequeUnClearAmount(M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId) AS 'ChequeUnclearAmount',
	 M.GradeId, M.DivisionId, M.AcademicYearId, S.StudentId
  FROM StudentGradeDivisionMapping M
       INNER JOIN Student S
       ON M.StudentId = S.StudentId
	    INNER JOIN @studentTemp t ON
	   S.StudentId = t.StudentId
  WHERE
   M.IsDeleted <> 1
   AND S.IsDeleted <> 1
   AND S.IsArchive <> 1
   AND (M.GradeId = ISNULL(@GradeId, M.GradeId) OR M.GradeId = @GradeId)
   AND (M.DivisionId = ISNULL(@DivisionId, M.DivisionId) OR M.DivisionId = @DivisionId)
   AND M.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (S.FirstName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.GeneralRegistrationNo LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.LastName LIKE '%'+@SearchText+'%')
   ));

 

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
  IF @OrderBy=0
  BEGIN
  SELECT 
     s.StudentId,
     G.GradeName + ' - ' + D.DivisionName AS GradeName,
     G.GradeId,
     D.DivisionId,
     M.AcademicYearId,
     S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName AS 'FullName',
     M.IsRTEStudent,
     S.GeneralRegistrationNo,
     temp.TotalFee AS 'TotalFee',
     temp.ChequeClearedAmount AS 'ChequeClearedAmount',
     temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
 FROM StudentGradeDivisionMapping M
       INNER JOIN Student S
       ON M.StudentId = S.StudentId
       INNER JOIN Grade G
       ON G.GradeId = M.GradeId
       INNER JOIN Division D
       ON D.DivisionId = M.DivisionId
	   INNER JOIN @temp3 temp
	   ON M.GradeId = temp.GradeId AND M.DivisionId = temp.DivisionId AND M.AcademicYearId = temp.AcademicYearId AND M.StudentId = temp.StudentId
	    INNER JOIN @studentTemp t ON
	   S.StudentId = t.StudentId

 WHERE
   M.IsDeleted <> 1
   AND S.IsDeleted <> 1
   AND S.IsArchive <> 1
  AND (M.GradeId = ISNULL(@GradeId, M.GradeId) OR M.GradeId = @GradeId)
   AND (M.DivisionId = ISNULL(@DivisionId, M.DivisionId) OR M.DivisionId = @DivisionId)
   AND M.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (S.FirstName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.LastName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.GeneralRegistrationNo LIKE '%'+@SearchText+'%')
   ))

 

 ORDER BY
 CASE WHEN @OrderBy=0 THEN len(G.GradeName + ' - ' + D.DivisionName) END DESC,G.GradeName + ' - ' + D.DivisionName DESC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
  END
 ELSE
 BEGIN
 SELECT 
     s.StudentId,
     G.GradeName + ' - ' + D.DivisionName AS GradeName,
     G.GradeId,
     D.DivisionId,
     M.AcademicYearId,
     S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName AS 'FullName',
     M.IsRTEStudent,
     S.GeneralRegistrationNo,
     temp.TotalFee AS 'TotalFee',
     temp.ChequeClearedAmount AS 'ChequeClearedAmount',
     temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
 FROM StudentGradeDivisionMapping M
       INNER JOIN Student S
       ON M.StudentId = S.StudentId
       INNER JOIN Grade G
       ON G.GradeId = M.GradeId
       INNER JOIN Division D
       ON D.DivisionId = M.DivisionId
	   INNER JOIN @temp3 temp
	   ON M.GradeId = temp.GradeId AND M.DivisionId = temp.DivisionId AND M.AcademicYearId = temp.AcademicYearId AND M.StudentId = temp.StudentId
	    INNER JOIN @studentTemp t ON
	   S.StudentId = t.StudentId

 WHERE
   M.IsDeleted <> 1
   AND S.IsDeleted <> 1
   AND S.IsArchive <> 1
  AND (M.GradeId = ISNULL(@GradeId, M.GradeId) OR M.GradeId = @GradeId)
   AND (M.DivisionId = ISNULL(@DivisionId, M.DivisionId) OR M.DivisionId = @DivisionId)
   AND M.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (S.FirstName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.LastName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.GeneralRegistrationNo LIKE '%'+@SearchText+'%')
   ))

 

 ORDER BY
 CASE WHEN @OrderBy=1 THEN S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName END DESC,
 CASE WHEN @OrderBy=2 THEN S.GeneralRegistrationNo END DESC,
 CASE WHEN @OrderBy=4 THEN temp.TotalFee END DESC,
 CASE WHEN @OrderBy=5 THEN temp.ChequeClearedAmount END DESC,
 CASE WHEN @OrderBy=6 THEN temp.ChequeUnclearAmount END DESC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
 END
END
ELSE
  BEGIN
  IF @OrderBy=0 
  BEGIN
  SELECT 
     s.StudentId,
     G.GradeName + ' - ' + D.DivisionName AS GradeName,
     G.GradeId,
     D.DivisionId,
     M.AcademicYearId,
     S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName AS 'FullName',
     M.IsRTEStudent,
     S.GeneralRegistrationNo,
     temp.TotalFee AS 'TotalFee',
     temp.ChequeClearedAmount AS 'ChequeClearedAmount',
     temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
 FROM StudentGradeDivisionMapping M
       INNER JOIN Student S
       ON M.StudentId = S.StudentId
       INNER JOIN Grade G
       ON G.GradeId = M.GradeId
       INNER JOIN Division D
       ON D.DivisionId = M.DivisionId
	   INNER JOIN @temp3 temp
	   ON M.GradeId = temp.GradeId AND M.DivisionId = temp.DivisionId AND M.AcademicYearId = temp.AcademicYearId AND M.StudentId = temp.StudentId
	    INNER JOIN @studentTemp t ON
	   S.StudentId = t.StudentId
      

 WHERE
   M.IsDeleted <> 1
   AND S.IsDeleted <> 1
   AND S.IsArchive <> 1
  AND (M.GradeId = ISNULL(@GradeId, M.GradeId) OR M.GradeId = @GradeId)
   AND (M.DivisionId = ISNULL(@DivisionId, M.DivisionId) OR M.DivisionId = @DivisionId)
   AND M.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (S.FirstName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.LastName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.GeneralRegistrationNo LIKE '%'+@SearchText+'%')
   ))

 

 ORDER BY
 CASE WHEN @OrderBy=0 THEN len(G.GradeName + ' - ' + D.DivisionName) END ASC,G.GradeName + ' - ' + D.DivisionName ASC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
  END
  ELSE
  BEGIN
  SELECT 
     s.StudentId,
     G.GradeName + ' - ' + D.DivisionName AS GradeName,
     G.GradeId,
     D.DivisionId,
     M.AcademicYearId,
     S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName AS 'FullName',
     M.IsRTEStudent,
     S.GeneralRegistrationNo,
     temp.TotalFee AS 'TotalFee',
     temp.ChequeClearedAmount AS 'ChequeClearedAmount',
     temp.ChequeUnclearAmount AS 'ChequeUnclearAmount'
 FROM StudentGradeDivisionMapping M
       INNER JOIN Student S
       ON M.StudentId = S.StudentId
       INNER JOIN Grade G
       ON G.GradeId = M.GradeId
       INNER JOIN Division D
       ON D.DivisionId = M.DivisionId
	   INNER JOIN @temp3 temp
	   ON M.GradeId = temp.GradeId AND M.DivisionId = temp.DivisionId AND M.AcademicYearId = temp.AcademicYearId AND M.StudentId = temp.StudentId
	    INNER JOIN @studentTemp t ON
	   S.StudentId = t.StudentId
      

 WHERE
   M.IsDeleted <> 1
   AND S.IsDeleted <> 1
   AND S.IsArchive <> 1
  AND (M.GradeId = ISNULL(@GradeId, M.GradeId) OR M.GradeId = @GradeId)
   AND (M.DivisionId = ISNULL(@DivisionId, M.DivisionId) OR M.DivisionId = @DivisionId)
   AND M.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName  LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (S.FirstName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.MiddleName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.LastName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (S.GeneralRegistrationNo LIKE '%'+@SearchText+'%')
   ))

 

 ORDER BY
 CASE WHEN @OrderBy=1 THEN S.FirstName + ' ' + S.MiddleName + ' ' + S.LastName END ASC,
 CASE WHEN @OrderBy=2 THEN S.GeneralRegistrationNo END ASC,
 CASE WHEN @OrderBy=4 THEN temp.TotalFee END ASC,
 CASE WHEN @OrderBy=5 THEN temp.ChequeClearedAmount END ASC,
 CASE WHEN @OrderBy=6 THEN temp.ChequeUnclearAmount END ASC
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