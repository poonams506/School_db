-- =============================================
-- Author:    Meena Kotkar
-- Create date: 09/99/2024
-- Description:  This stored procedure is used to get Fee payment history deatils for grid
-- =============================================
CREATE PROCEDURE [dbo].[uspRegistrationHistoryGridSelect]
	@RequestModel NVARCHAR(MAX)
AS
BEGIN
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY
 DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
 DECLARE @StudentEnquiryId BIGINT = JSON_VALUE(@RequestModel, '$.StudentEnquiryId');
 DECLARE @PageSize INT=JSON_VALUE(@RequestModel, '$.getListModel.length');
 DECLARE @PageNumber INT=JSON_VALUE(@RequestModel, '$.getListModel.start');
 DECLARE @SearchText NVARCHAR(150)=JSON_VALUE(@RequestModel, '$.getListModel.search.value');
 DECLARE @OrderBy INT=JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
 DECLARE @OrderBy_ASC_DESC NVARCHAR(20)=JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');
 
  DECLARE @FeePaymentTypeTable TABLE(
   PaymentTypeId TINYINT,
   PaymentTypeName NVARCHAR(50)
  )

  INSERT INTO @FeePaymentTypeTable(PaymentTypeId, PaymentTypeName) VALUES (1,'Cash'),(2,'Cheque'),(3,'DD'),(4,'Credit/Debit Card'),(5,'Net Banking'),(6,'UPI Payment');

  SELECT COUNT(r.RegistrationFeeId)
  FROM RegistrationFee r
  INNER JOIN @FeePaymentTypeTable t
  ON r.PaymentTypeId = t.PaymentTypeId
  WHERE
       r.IsDeleted <> 1
   AND r.AcademicYearId = @AcademicYearId
   AND r.StudentEnquiryId = @StudentEnquiryId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (r.OnlineTransactionDateTime LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (r.RegistrationInvoiceNumber LIKE '%'+@SearchText+'%')    
   OR  LEN(@SearchText)>0 AND (r.PaidAmount LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (t.PaymentTypeName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (r.OnlineTransactionId LIKE '%'+@SearchText+'%') 
  ));

  IF(@OrderBy_ASC_DESC='desc')
 BEGIN
                          
 SELECT row_number() over(order by RegistrationFeeId asc) as InstallmentNumber,
  r.RegistrationInvoiceNumber,
  r.RegistrationFeeId,
  r.OnlineTransactionDateTime,
  r.PaidAmount,
  t.PaymentTypeName,
  r.OnlineTransactionId AS OnlineTransactionId
  FROM RegistrationFee r
  INNER JOIN @FeePaymentTypeTable t
  ON r.PaymentTypeId = t.PaymentTypeId
  WHERE
       r.IsDeleted <> 1
   AND r.StudentEnquiryId = @StudentEnquiryId
   AND r.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (r.OnlineTransactionDateTime LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (r.RegistrationInvoiceNumber LIKE '%'+@SearchText+'%')    
   OR  LEN(@SearchText)>0 AND (r.PaidAmount LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (t.PaymentTypeName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (r.OnlineTransactionId LIKE '%'+@SearchText+'%') 
  ))

 ORDER BY
 CASE WHEN @OrderBy=0 THEN r.RegistrationInvoiceNumber END DESC,
 CASE WHEN @OrderBy=1 THEN r.OnlineTransactionDateTime END DESC,
 CASE WHEN @OrderBy=2 THEN r.PaidAmount END DESC,
 CASE WHEN @OrderBy=3 THEN t.PaymentTypeName END DESC,
 CASE WHEN @OrderBy=4 THEN r.OnlineTransactionId END DESC
 OFFSET @PageNumber ROWS
 FETCH NEXT @PageSize ROWS ONLY
END
ELSE
  BEGIN
                           
         
  SELECT row_number() over(order by RegistrationFeeId asc) as InstallmentNumber,
  r.RegistrationInvoiceNumber,
  r.OnlineTransactionDateTime,
  r.PaidAmount,
  t.PaymentTypeName,
  r.OnlineTransactionId AS OnlineTransactionId,
  r.RegistrationFeeId
  FROM RegistrationFee r
  INNER JOIN @FeePaymentTypeTable t
  ON r.PaymentTypeId = t.PaymentTypeId
  WHERE
       r.IsDeleted <> 1
   AND r.StudentEnquiryId = @StudentEnquiryId
   AND r.AcademicYearId = @AcademicYearId
   AND (LEN(@SearchText)=0 
   OR  LEN(@SearchText)>0 AND (r.OnlineTransactionDateTime LIKE '%'+@SearchText+'%'
   OR  LEN(@SearchText)>0 AND (r.RegistrationInvoiceNumber LIKE '%'+@SearchText+'%')    
   OR  LEN(@SearchText)>0 AND (r.PaidAmount LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (t.PaymentTypeName LIKE '%'+@SearchText+'%')
   OR  LEN(@SearchText)>0 AND (r.OnlineTransactionId LIKE '%'+@SearchText+'%') 
   ))

 ORDER BY
 CASE WHEN @OrderBy=0 THEN r.RegistrationInvoiceNumber END ASC,
 CASE WHEN @OrderBy=1 THEN r.OnlineTransactionDateTime END ASC,
 CASE WHEN @OrderBy=2 THEN r.PaidAmount END ASC,
 CASE WHEN @OrderBy=3 THEN t.PaymentTypeName END ASC,
 CASE WHEN @OrderBy=4 THEN r.OnlineTransactionId END ASC
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