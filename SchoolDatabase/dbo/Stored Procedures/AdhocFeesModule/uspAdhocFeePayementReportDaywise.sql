﻿-- =============================================
-- Author:   Shambala Apugade
-- Create date: 29/05/2024
-- Description:  This stored procedure is used to get Adhoc Fee Payment Daywise Report  
-- =============================================
CREATE PROC [dbo].[uspAdhocFeePaymentReportDaywise](@StartDate DateTime,@EndDate DateTime) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

DECLARE @TempPaymentReportDaywise TABLE(
StudentName nvarchar(MAX),GeneralRegistrationNo nvarchar(100),AcademicYearName nvarchar(10),Class nvarchar(10),PaymentAmount decimal(18,2),InvoiceNumber nvarchar(100),
TransactionDate datetime,PaymentMode nvarchar(25),ChequeUnclearedAmount decimal(18,2),
TransactionId nvarchar(1000),TransactionBy nvarchar(100),ChequeNumber nvarchar(100),ChequeDate datetime, ChequeBank nvarchar(100)
)
INSERT INTO @TempPaymentReportDaywise(StudentName,GeneralRegistrationNo,AcademicYearName,Class,PaymentAmount ,InvoiceNumber,
TransactionDate,PaymentMode,ChequeUnclearedAmount,
TransactionId,TransactionBy,ChequeNumber,ChequeDate,ChequeBank)

SELECT s.FirstName+' '+s.LastName AS StudentName, s.GeneralRegistrationNo,a.AcademicYearName, g.GradeName +'-'+ d.DivisionName AS Class,
fp.TotalFee AS PaymentAmount,
fp.InvoiceNumber,fp.OnlineTransactionDateTime AS TransactionDate,
CASE WHEN fp.PaymentTypeId = 1 THEN 'Cash'
 WHEN fp.PaymentTypeId = 2 THEN 'Cheque'
 WHEN fp.PaymentTypeId = 3 THEN 'DD'
 WHEN fp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
 WHEN fp.PaymentTypeId = 5 THEN 'NetBanking'
 WHEN fp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentMode,

CASE WHEN (fp.PaymentTypeId = 2 OR fp.PaymentTypeId =3 ) AND fp.IsChequeClear = 0 THEN fp.TotalFee ELSE 0.00 END AS ChequeUnclearedAmount,
fp.OnlineTransactionId AS TransactionId,

u.Fname +' '+ u.Lname AS TransactionBy,
fp.ChequeNumber,fp.ChequeDate, fp.ChequeBank


FROM [dbo].[AdhocFeePayment] fp
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
INNER JOIN [User] u
ON fp.CreatedBy = u.UserId

WHERE  CAST(fp.OnlineTransactionDateTime AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)

--- For Negative Entry

INSERT INTO @TempPaymentReportDaywise(StudentName,GeneralRegistrationNo,AcademicYearName,Class,PaymentAmount ,InvoiceNumber,
TransactionDate,PaymentMode,ChequeUnclearedAmount,
TransactionId,TransactionBy,ChequeNumber,ChequeDate,ChequeBank)
SELECT s.FirstName+' '+s.LastName AS StudentName, s.GeneralRegistrationNo,a.AcademicYearName, g.GradeName +'-'+ d.DivisionName AS Class,
CASE WHEN fp.IsDeleted = 1 THEN fp.TotalFee * -1 ELSE fp.TotalFee END AS PaymentAmount,
fp.InvoiceNumber,fp.OnlineTransactionDateTime AS TransactionDate,
CASE WHEN fp.PaymentTypeId = 1 THEN 'Cash'
 WHEN fp.PaymentTypeId = 2 THEN 'Cheque'
 WHEN fp.PaymentTypeId = 3 THEN 'DD'
 WHEN fp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
 WHEN fp.PaymentTypeId = 5 THEN 'NetBanking'
 WHEN fp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentMode,

CASE WHEN (fp.PaymentTypeId = 2 OR fp.PaymentTypeId =3 ) AND fp.IsChequeClear = 0 THEN fp.TotalFee ELSE 0.00 END AS ChequeUnclearedAmount,
fp.OnlineTransactionId AS TransactionId,

mu.Fname +' '+ mu.Lname AS TransactionBy,
fp.ChequeNumber,fp.ChequeDate, fp.ChequeBank


FROM [dbo].[AdhocFeePayment] fp
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
INNER JOIN [User] mu
ON fp.ModifiedBy= mu.UserId

WHERE  CAST(fp.OnlineTransactionDateTime AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE) AND fp.IsDeleted = 1

--Cash
SELECT * FROM @TempPaymentReportDaywise WHERE  PaymentMode ='Cash'  ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempPaymentReportDaywise where PaymentMode ='Cash'

--Cheque
SELECT * FROM @TempPaymentReportDaywise WHERE  PaymentMode ='Cheque'  ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempPaymentReportDaywise where PaymentMode ='Cheque'

--DD
SELECT * FROM @TempPaymentReportDaywise WHERE  PaymentMode ='DD'  ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempPaymentReportDaywise where PaymentMode ='DD'

--Credit/Debit Card
SELECT * FROM @TempPaymentReportDaywise WHERE  PaymentMode ='Credit/Debit Card'  ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempPaymentReportDaywise where PaymentMode ='Credit/Debit Card'

--NetBanking
SELECT * FROM @TempPaymentReportDaywise WHERE  PaymentMode ='NetBanking' ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempPaymentReportDaywise where PaymentMode ='NetBanking'

--UPI Payment
SELECT * FROM @TempPaymentReportDaywise WHERE  PaymentMode ='UPI Payment' ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempPaymentReportDaywise where PaymentMode ='UPI Payment'

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
