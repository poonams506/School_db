-- =============================================
-- Author:    Deepa Walunj
-- Create date: 15/19/2023
-- Description:  This stored procedure is used to get Fee payment history deatils for grid
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentKitFeePaymentHistoryGridSelect]
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
 DECLARE @StudentId BIGINT = JSON_VALUE(@RequestModel, '$.studentId');
 DECLARE @PageSize INT=JSON_VALUE(@RequestModel, '$.getListModel.length');
 DECLARE @PageNumber INT=JSON_VALUE(@RequestModel, '$.getListModel.start');
 DECLARE @SearchText NVARCHAR(150)=JSON_VALUE(@RequestModel, '$.getListModel.search.value');
 DECLARE @OrderBy INT=JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
 DECLARE @OrderBy_ASC_DESC NVARCHAR(20)=JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');
 
  DECLARE @StudentKitFeePaymentTypeTable TABLE(
   PaymentTypeId TINYINT,
   PaymentTypeName NVARCHAR(50)
  )

  INSERT INTO @StudentKitFeePaymentTypeTable(PaymentTypeId, PaymentTypeName) VALUES (1,'Cash'),(2,'Cheque'),(3,'DD'),(4,'Credit/Debit Card'),(5,'Net Banking'),(6,'UPI Payment');

  SELECT COUNT(f.StudentKitFeePaymentId)
  FROM StudentKitFeePayment f
  INNER JOIN @StudentKitFeePaymentTypeTable t
  ON f.PaymentTypeId = t.PaymentTypeId
  WHERE
       f.IsDeleted <> 1
   AND f.GradeId = @GradeId
   AND f.DivisionId = @DivisionId
   AND f.AcademicYearId = @AcademicYearId
   AND f.StudentId = @StudentId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (f.OnlineTransactionDateTime LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (f.InvoiceNumber LIKE '%'+@SearchText+'%')    
   OR  LEN(@SearchText)>0 AND (f.PaidAmount LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (t.PaymentTypeName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (f.ChequeDate LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, 'Yes', 'No'),'') LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (f.OnlineTransactionId LIKE '%'+@SearchText+'%') 
   OR  LEN(@SearchText)>0 AND (f.ChequeNumber LIKE '%'+@SearchText+'%') 
   ));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT row_number() over(order by StudentKitFeePaymentId asc) as InstallmentNumber,
  f.InvoiceNumber,
  f.OnlineTransactionDateTime,
  f.PaidAmount,
  t.PaymentTypeName,
  f.ChequeDate,
  IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, 'Yes', 'No'),'') AS IsChequeOrDDClear,
  IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, f.ChequeNumber, f.ChequeNumber),f.OnlineTransactionId) AS OnlineTransactionId,
  f.StudentKitFeePaymentId
  FROM StudentKitFeePayment f
  INNER JOIN @StudentKitFeePaymentTypeTable t
  ON f.PaymentTypeId = t.PaymentTypeId
  WHERE
       f.IsDeleted <> 1
   AND f.GradeId = @GradeId
   AND f.DivisionId = @DivisionId
   AND f.StudentId = @StudentId
   AND f.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (f.OnlineTransactionDateTime LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (f.InvoiceNumber LIKE '%'+@SearchText+'%')    
   OR  LEN(@SearchText)>0 AND (f.PaidAmount LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (t.PaymentTypeName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (f.ChequeDate LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, 'Yes', 'No'),'') LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (f.OnlineTransactionId LIKE '%'+@SearchText+'%') 
   OR  LEN(@SearchText)>0 AND (f.ChequeNumber LIKE '%'+@SearchText+'%') 
   ))

 ORDER BY
 CASE WHEN @OrderBy=0 THEN row_number() over(order by StudentKitFeePaymentId asc) END DESC,
 CASE WHEN @OrderBy=1 THEN f.InvoiceNumber END DESC,
 CASE WHEN @OrderBy=2 THEN f.OnlineTransactionDateTime END DESC,
 CASE WHEN @OrderBy=3 THEN f.PaidAmount END DESC,
 CASE WHEN @OrderBy=4 THEN t.PaymentTypeName END DESC,
 CASE WHEN @OrderBy=5 THEN f.ChequeDate END DESC,
 CASE WHEN @OrderBy=6 THEN IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, 'Yes', 'No'),'') END DESC,
 CASE WHEN @OrderBy=7 THEN f.OnlineTransactionId END DESC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
END
ELSE
  BEGIN
                           
         
  SELECT row_number() over(order by StudentKitFeePaymentId asc) as InstallmentNumber,
  f.InvoiceNumber,
  f.OnlineTransactionDateTime,
  f.PaidAmount,
  t.PaymentTypeName,
  f.ChequeDate,
  IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, 'Yes', 'No'),'') AS IsChequeOrDDClear,
  IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, f.ChequeNumber, f.ChequeNumber),f.OnlineTransactionId) AS OnlineTransactionId,
  f.StudentKitFeePaymentId
  FROM StudentKitFeePayment f
  INNER JOIN @StudentKitFeePaymentTypeTable t
  ON f.PaymentTypeId = t.PaymentTypeId
  WHERE
       f.IsDeleted <> 1
   AND f.GradeId = @GradeId
   AND f.DivisionId = @DivisionId
   AND f.AcademicYearId = @AcademicYearId
   AND f.StudentId = @StudentId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (f.OnlineTransactionDateTime LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (f.InvoiceNumber LIKE '%'+@SearchText+'%')    
   OR  LEN(@SearchText)>0 AND (f.PaidAmount LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (t.PaymentTypeName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (f.ChequeDate LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, 'Yes', 'No'),'') LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (f.OnlineTransactionId LIKE '%'+@SearchText+'%') 
   OR  LEN(@SearchText)>0 AND (f.ChequeNumber LIKE '%'+@SearchText+'%') 
   ))

 ORDER BY
 CASE WHEN @OrderBy=0 THEN row_number() over(order by StudentKitFeePaymentId asc) END ASC,
 CASE WHEN @OrderBy=1 THEN f.InvoiceNumber END ASC,
 CASE WHEN @OrderBy=2 THEN f.OnlineTransactionDateTime END ASC,
 CASE WHEN @OrderBy=3 THEN f.PaidAmount END ASC,
 CASE WHEN @OrderBy=4 THEN t.PaymentTypeName END ASC,
 CASE WHEN @OrderBy=5 THEN f.ChequeDate END ASC,
 CASE WHEN @OrderBy=6 THEN IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, 'Yes', 'No'),'') END ASC,
 CASE WHEN @OrderBy=7 THEN f.OnlineTransactionId END ASC
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
@ErrorState END CATCH
END