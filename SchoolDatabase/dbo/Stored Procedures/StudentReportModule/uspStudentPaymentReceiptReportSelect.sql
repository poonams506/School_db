
-- =============================================
-- Author:    Shambala Apugade
-- Create date: 08/08/2024
-- Description:  This stored procedure is used to get All Fee Payment Receipt detail 
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentPaymentReceiptReportSelect]
	@AcademicYearId SMALLINT,
	@StudentId BIGINT,
	@ClassId INT

AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
   DECLARE @GradeId INT, @DivisionId INT;
  
    SELECT 
        @GradeId = sgdm.GradeId,
        @DivisionId = sgdm.DivisionId
    FROM  
        dbo.SchoolGradeDivisionMatrix sgdm
        INNER JOIN dbo.Grade g ON sgdm.GradeId = g.GradeId
        INNER JOIN dbo.Division d ON sgdm.DivisionId = d.DivisionId
    WHERE 
        sgdm.IsDeleted <> 1 
        AND sgdm.SchoolGradeDivisionMatrixId = @ClassId
        AND sgdm.AcademicYearId = @AcademicYearId;
DECLARE @TempReciptTable Table(ReceiptType nvarchar(100),ReceiptId bigint,InvoiceNumber Varchar(100),OnlineTransactionDateTime datetime,PaidAmount money,PaymentType nvarchar(25), 
ChequeDate Datetime, IsChequeClear bit,TransactionId nvarchar(1000),TransportConsumerStoppageMappingId int null)
INSERT INTO @TempReciptTable (ReceiptType, ReceiptId,InvoiceNumber,OnlineTransactionDateTime,PaidAmount,PaymentType,ChequeDate,IsChequeClear,TransactionId,TransportConsumerStoppageMappingId)

---ACADEMIC FEE RECEIPT
SELECT 
	'Academic Fee' AS ReceiptType ,fp.FeePaymentId AS ReceiptId,fp.InvoiceNumber,fp.OnlineTransactionDateTime,fp.PaidAmount,
	CASE WHEN fp.PaymentTypeId = 1 THEN 'Cash'
	WHEN fp.PaymentTypeId = 2 THEN 'Cheque'
	WHEN fp.PaymentTypeId = 3 THEN 'DD'
	WHEN fp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
	WHEN fp.PaymentTypeId = 5 THEN 'NetBanking'
	WHEN fp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentType,
	fp.ChequeDate,fp.IsChequeClear,
	IIF(fp.PaymentTypeId = 2 OR fp.PaymentTypeId = 3, fp.ChequeNumber, fp.OnlineTransactionId) AS TransactionId,
	NULL

FROM [dbo].[FeePayment] fp
	INNER JOIN Student s
	ON s.StudentId = fp.StudentId
	INNER JOIN
	StudentGradeDivisionMapping M
	ON M.StudentId = S.StudentId AND M.AcademicYearId = fp.AcademicYearId
	INNER JOIN school sc
	ON s.SchoolId =sc.SchoolId
	INNER JOIN Grade g
	ON m.GradeId = g.GradeId
	INNER JOIN Division d
	ON m.DivisionId = d.DivisionId
	INNER JOIN AcademicYear a
	ON m.AcademicYearId = a.AcademicYearId

WHERE ISNULL(s.IsDeleted,0) <> 1
	AND ISNULL(m.IsDeleted,0) <> 1
	AND s.IsArchive <> 1
	AND ISNULL(g.IsDeleted,0) <> 1
	AND ISNULL(d.IsDeleted,0) <> 1
	AND ISNULL(fp.IsDeleted,0) <> 1
	AND m.AcademicYearId = @AcademicYearId
	AND m.StudentId = @StudentId
	AND m.GradeId = @GradeId
	AND m.DivisionId = @DivisionId

---- ADHOC FEE RECEIPT
UNION
SELECT  
	'Additional Fee' AS ReceiptType,ap.AdhocFeePaymentId AS ReceiptId,ap.InvoiceNumber,ap.OnlineTransactionDateTime,ap.TotalFee,
	CASE WHEN ap.PaymentTypeId = 1 THEN 'Cash'
	WHEN ap.PaymentTypeId = 2 THEN 'Cheque'
	WHEN ap.PaymentTypeId = 3 THEN 'DD'
	WHEN ap.PaymentTypeId = 4 THEN 'Credit/Debit Card'
	WHEN ap.PaymentTypeId = 5 THEN 'NetBanking'
	WHEN ap.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentType,
	ap.ChequeDate,ap.IsChequeClear,
	IIF(ap.PaymentTypeId = 2 OR ap.PaymentTypeId = 3, ap.ChequeNumber, ap.OnlineTransactionId) AS TransactionId,
	NULL
FROM [dbo].[AdhocFeePayment] ap
	INNER JOIN Student s
	ON s.StudentId = ap.StudentId
	INNER JOIN
	StudentGradeDivisionMapping M
	ON M.StudentId = S.StudentId AND M.AcademicYearId = ap.AcademicYearId
	INNER JOIN school sc
	ON s.SchoolId =sc.SchoolId
	INNER JOIN Grade g
	ON m.GradeId = g.GradeId
	INNER JOIN Division d
	ON m.DivisionId = d.DivisionId
	INNER JOIN AcademicYear a
	ON m.AcademicYearId = a.AcademicYearId

WHERE ISNULL(s.IsDeleted,0) <> 1
	AND ISNULL(m.IsDeleted,0) <> 1
	AND s.IsArchive <> 1
	AND ISNULL(g.IsDeleted,0) <> 1
	AND ISNULL(d.IsDeleted,0) <> 1
	AND ISNULL(ap.IsDeleted,0) <> 1
	AND m.AcademicYearId = @AcademicYearId
	AND m.StudentId = @StudentId
	AND m.GradeId = @GradeId
	AND m.DivisionId = @DivisionId

---STUDENTKIT FEE RECEIPT
UNION
SELECT 
	'Student Kit Fee' AS ReceiptType,sp.StudentKitFeePaymentId AS ReceiptId,sp.InvoiceNumber,sp.OnlineTransactionDateTime,sp.PaidAmount,
	CASE WHEN sp.PaymentTypeId = 1 THEN 'Cash'
	WHEN sp.PaymentTypeId = 2 THEN 'Cheque'
	WHEN sp.PaymentTypeId = 3 THEN 'DD'
	WHEN sp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
	WHEN sp.PaymentTypeId = 5 THEN 'NetBanking'
	WHEN sp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentType,
	sp.ChequeDate,sp.IsChequeClear,
	IIF(sp.PaymentTypeId = 2 OR sp.PaymentTypeId = 3, sp.ChequeNumber, sp.OnlineTransactionId) AS TransactionId,
	NULL

FROM [dbo].[StudentKitFeePayment] sp
	INNER JOIN Student s
	ON s.StudentId = sp.StudentId
	INNER JOIN
	StudentGradeDivisionMapping M
	ON M.StudentId = S.StudentId AND M.AcademicYearId = sp.AcademicYearId
	INNER JOIN school sc
	ON s.SchoolId =sc.SchoolId
	INNER JOIN Grade g
	ON m.GradeId = g.GradeId
	INNER JOIN Division d
	ON m.DivisionId = d.DivisionId
	INNER JOIN AcademicYear a
	ON m.AcademicYearId = a.AcademicYearId

WHERE ISNULL(s.IsDeleted,0) <> 1
	AND ISNULL(m.IsDeleted,0) <> 1
	AND s.IsArchive <> 1
	AND ISNULL(g.IsDeleted,0) <> 1
	AND ISNULL(d.IsDeleted,0) <> 1
	AND ISNULL(sp.IsDeleted,0) <> 1
	AND m.AcademicYearId = @AcademicYearId
	AND m.StudentId = @StudentId
	AND m.GradeId = @GradeId
	AND m.DivisionId = @DivisionId

---TRANSPORT FEE RECEIPT
UNION
SELECT 
	'Transport Fee' AS ReceiptType,tp.TransportFeePaymentId AS ReceiptId,tp.InvoiceNumber,tp.OnlineTransactionDateTime,tp.PaidAmount,
	CASE WHEN tp.PaymentTypeId = 1 THEN 'Cash'
	WHEN tp.PaymentTypeId = 2 THEN 'Cheque'
	WHEN tp.PaymentTypeId = 3 THEN 'DD'
	WHEN tp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
	WHEN tp.PaymentTypeId = 5 THEN 'NetBanking'
	WHEN tp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentType,
	tp.ChequeDate,tp.IsChequeClear,
	IIF(tp.PaymentTypeId = 2 OR tp.PaymentTypeId = 3, tp.ChequeNumber, tp.OnlineTransactionId) AS TransactionId,
	tp.TransportConsumerStoppageMappingId

FROM 
	TransportFeePayment tp
	INNER JOIN Student s
    ON tp.ConsumerId = s.StudentId AND tp.RoleId = 5
	INNER JOIN StudentGradeDivisionMapping M
    ON M.StudentId = S.StudentId AND M.AcademicYearId = tp.AcademicYearId
	INNER JOIN Grade g
	ON m.GradeId = g.GradeId
	INNER JOIN Division d
	ON m.DivisionId = d.DivisionId
	INNER JOIN [User] u
	ON tp.CreatedBy = u.UserId
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = tp.AcademicYearId

WHERE ISNULL(s.IsDeleted,0) <> 1
	AND ISNULL(m.IsDeleted,0) <> 1
	AND s.IsArchive <> 1
	AND ISNULL(g.IsDeleted,0) <> 1
	AND ISNULL(d.IsDeleted,0) <> 1
	AND ISNULL(tp.IsDeleted,0) <> 1
	AND m.AcademicYearId = @AcademicYearId
	AND m.StudentId = @StudentId
	AND m.GradeId = @GradeId
	AND m.DivisionId = @DivisionId

ORDER BY  OnlineTransactionDateTime asc

 ---STUDENT INFO
SELECT 
	s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName AS 'FullName',
	s.StudentId,
	s.GeneralRegistrationNo,
	s.IsNewStudent,
	m.IsRTEStudent,
	s.EmergencyContactNumber,
	m.AcademicYearId,
	m.RollNumber,
	g.GradeName,
	d.DivisionName
	
FROM Student s
	INNER JOIN StudentGradeDivisionMapping m
	ON s.StudentId = m.StudentId
	INNER JOIN Grade g
	ON m.GradeId = m.GradeId
	INNER JOIN Division d
	ON m.DivisionId = d.DivisionId
	
WHERE ISNULL(s.IsDeleted,0) <> 1
	AND ISNULL(s.IsArchive,0) <> 1
	AND ISNULL(m.IsDeleted,0) <> 1
	AND ISNULL(g.IsDeleted,0) <> 1
	AND ISNULL(d.IsDeleted,0) <> 1
	AND m.AcademicYearId = @AcademicYearId
	AND m.StudentId = @StudentId
	AND m.GradeId = @GradeId
	AND m.DivisionId = @DivisionId
	AND g.GradeId = @GradeId
	AND d.DivisionId = @DivisionId

SELECT * FROM  @TempReciptTable

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
GO


