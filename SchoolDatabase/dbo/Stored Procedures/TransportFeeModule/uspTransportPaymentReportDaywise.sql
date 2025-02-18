-- =============================================
-- Author:    Shambala Apugade
-- Create date: 26/05/2024
-- Description:  This stored procedure is used to get Transport Payment Datewise report
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportPaymentReportDaywise] (@StartDate DateTime,@EndDate DateTime)
AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 


DECLARE @TempTransportPaymentReportDaywise TABLE(
FullName nvarchar(MAX),AcademicYearName nvarchar(10),UserType nvarchar(10),PaymentAmount decimal(18,2),InvoiceNumber nvarchar(100),
TransactionDate datetime,PaymentMode nvarchar(25),ChequeUnclearedAmount decimal(18,2),
TransactionId nvarchar(1000),TransactionBy nvarchar(100),ChequeNumber nvarchar(100),ChequeDate datetime, ChequeBank nvarchar(100)
)
INSERT INTO @TempTransportPaymentReportDaywise(FullName,AcademicYearName,UserType,PaymentAmount ,InvoiceNumber,
TransactionDate,PaymentMode,ChequeUnclearedAmount,TransactionId,TransactionBy,ChequeNumber,ChequeDate,ChequeBank)

---STUDENT
SELECT CONCAT(
            COALESCE(T.FirstName + ' ', '')
            , COALESCE(T.MiddleName + ' ', '')
            , COALESCE(T.LastName,'')
        ) AS FullName,
		a.AcademicYearName,
		'Student' AS UserType,
tp.PaidAmount AS PaymentAmount,
tp.InvoiceNumber,tp.OnlineTransactionDateTime AS TransactionDate,
CASE WHEN tp.PaymentTypeId = 1 THEN 'Cash'
 WHEN tp.PaymentTypeId = 2 THEN 'Cheque'
 WHEN tp.PaymentTypeId = 3 THEN 'DD'
 WHEN tp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
 WHEN tp.PaymentTypeId = 5 THEN 'NetBanking'
 WHEN tp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentMode,

CASE WHEN (tp.PaymentTypeId = 2 OR tp.PaymentTypeId =3 ) AND tp.IsChequeClear = 0 THEN tp.PaidAmount ELSE 0.00 END AS ChequeUnclearedAmount,
tp.OnlineTransactionId AS TransactionId,
u.Fname + ' '+ u.Lname AS TransactionBy,
tp.ChequeNumber,tp.ChequeDate, tp.ChequeBank

FROM 
	TransportFeePayment tp
	INNER JOIN Student T
    ON tp.ConsumerId = T.StudentId AND tp.RoleId = 5
	INNER JOIN [User] u
	ON tp.CreatedBy = u.UserId
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = tp.AcademicYearId

WHERE  CAST(tp.OnlineTransactionDateTime AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)

UNION
---TEACHER
SELECT CONCAT(
            COALESCE(T.FirstName + ' ', '')
            , COALESCE(T.MiddleName + ' ', '')
            , COALESCE(T.LastName,'')
        ) AS FullName,
		a.AcademicYearName,
		r.RoleKey AS UserType,
tp.PaidAmount AS PaymentAmount,
tp.InvoiceNumber,tp.OnlineTransactionDateTime AS TransactionDate,
CASE WHEN tp.PaymentTypeId = 1 THEN 'Cash'
 WHEN tp.PaymentTypeId = 2 THEN 'Cheque'
 WHEN tp.PaymentTypeId = 3 THEN 'DD'
 WHEN tp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
 WHEN tp.PaymentTypeId = 5 THEN 'NetBanking'
 WHEN tp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentMode,

CASE WHEN (tp.PaymentTypeId = 2 OR tp.PaymentTypeId =3 ) AND tp.IsChequeClear = 0 THEN tp.PaidAmount ELSE 0.00 END AS ChequeUnclearedAmount,
tp.OnlineTransactionId AS TransactionId,
u.Fname + ' '+ u.Lname AS TransactionBy,
tp.ChequeNumber,tp.ChequeDate, tp.ChequeBank

FROM 
	TransportFeePayment tp
	INNER JOIN Teacher T
    ON tp.ConsumerId = T.TeacherId AND tp.RoleId = 3
	INNER JOIN [Role] r
	ON tp.RoleId = r.RoleId
	INNER JOIN [User] u
	ON tp.CreatedBy = u.UserId
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = tp.AcademicYearId

WHERE  CAST(tp.OnlineTransactionDateTime AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)

UNION
---CLERK

SELECT CONCAT(
            COALESCE(T.FirstName + ' ', '')
            , COALESCE(T.MiddleName + ' ', '')
            , COALESCE(T.LastName,'')
        ) AS FullName,
		a.AcademicYearName,
		r.RoleKey AS UserType,
tp.PaidAmount AS PaymentAmount,
tp.InvoiceNumber,tp.OnlineTransactionDateTime AS TransactionDate,
CASE WHEN tp.PaymentTypeId = 1 THEN 'Cash'
 WHEN tp.PaymentTypeId = 2 THEN 'Cheque'
 WHEN tp.PaymentTypeId = 3 THEN 'DD'
 WHEN tp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
 WHEN tp.PaymentTypeId = 5 THEN 'NetBanking'
 WHEN tp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentMode,

CASE WHEN (tp.PaymentTypeId = 2 OR tp.PaymentTypeId =3 ) AND tp.IsChequeClear = 0 THEN tp.PaidAmount ELSE 0.00 END AS ChequeUnclearedAmount,
tp.OnlineTransactionId AS TransactionId,
u.Fname + ' '+ u.Lname AS TransactionBy,
tp.ChequeNumber,tp.ChequeDate, tp.ChequeBank

FROM 
	TransportFeePayment tp
	INNER JOIN Clerk T
    ON tp.ConsumerId = T.ClerkId  AND tp.RoleId = 4
	INNER JOIN [Role] r
	ON tp.RoleId = r.RoleId
	INNER JOIN [User] u
	ON tp.CreatedBy = u.UserId
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = tp.AcademicYearId
WHERE  CAST(tp.OnlineTransactionDateTime AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)


UNION 
---CAB DRIVER

SELECT CONCAT(
            COALESCE(T.FirstName + ' ', '')
            , COALESCE(T.MiddleName + ' ', '')
            , COALESCE(T.LastName,'')
        ) AS FullName,
		a.AcademicYearName,
		r.RoleKey AS UserType,
tp.PaidAmount AS PaymentAmount,
tp.InvoiceNumber,tp.OnlineTransactionDateTime AS TransactionDate,
CASE WHEN tp.PaymentTypeId = 1 THEN 'Cash'
 WHEN tp.PaymentTypeId = 2 THEN 'Cheque'
 WHEN tp.PaymentTypeId = 3 THEN 'DD'
 WHEN tp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
 WHEN tp.PaymentTypeId = 5 THEN 'NetBanking'
 WHEN tp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentMode,

CASE WHEN (tp.PaymentTypeId = 2 OR tp.PaymentTypeId =3 ) AND tp.IsChequeClear = 0 THEN tp.PaidAmount ELSE 0.00 END AS ChequeUnclearedAmount,
tp.OnlineTransactionId AS TransactionId,
u.Fname + ' '+ u.Lname AS TransactionBy,
tp.ChequeNumber,tp.ChequeDate, tp.ChequeBank

FROM 
	TransportFeePayment tp
	INNER JOIN CabDriver T
    ON tp.ConsumerId = T.CabDriverId  AND tp.RoleId = 6
	INNER JOIN [Role] r
	ON tp.RoleId = r.RoleId
	INNER JOIN [User] u
	ON tp.CreatedBy = u.UserId
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = tp.AcademicYearId

WHERE  CAST(tp.OnlineTransactionDateTime AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)

---for negative Entry

INSERT INTO @TempTransportPaymentReportDaywise(FullName,AcademicYearName,UserType,PaymentAmount ,InvoiceNumber,
TransactionDate,PaymentMode,ChequeUnclearedAmount,TransactionId,TransactionBy,ChequeNumber,ChequeDate,ChequeBank)

---STUDENT
SELECT CONCAT(
            COALESCE(T.FirstName + ' ', '')
            , COALESCE(T.MiddleName + ' ', '')
            , COALESCE(T.LastName,'')
        ) AS FullName,
		a.AcademicYearName,
		'Student' AS UserType,
CASE WHEN tp.IsDeleted = 1 THEN tp.PaidAmount * -1 ELSE tp.PaidAmount END AS PaymentAmount,
tp.InvoiceNumber,tp.OnlineTransactionDateTime AS TransactionDate,
CASE WHEN tp.PaymentTypeId = 1 THEN 'Cash'
 WHEN tp.PaymentTypeId = 2 THEN 'Cheque'
 WHEN tp.PaymentTypeId = 3 THEN 'DD'
 WHEN tp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
 WHEN tp.PaymentTypeId = 5 THEN 'NetBanking'
 WHEN tp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentMode,

CASE WHEN (tp.PaymentTypeId = 2 OR tp.PaymentTypeId =3 ) AND tp.IsChequeClear = 0 THEN tp.PaidAmount ELSE 0.00 END AS ChequeUnclearedAmount,
tp.OnlineTransactionId AS TransactionId,
u.Fname + ' '+ u.Lname AS TransactionBy,
tp.ChequeNumber,tp.ChequeDate, tp.ChequeBank

FROM 
	TransportFeePayment tp
	INNER JOIN Student T
    ON tp.ConsumerId = T.StudentId AND tp.RoleId = 5
	INNER JOIN [User] u
	ON tp.CreatedBy = u.UserId
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = tp.AcademicYearId


WHERE CAST(tp.OnlineTransactionDateTime AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE) AND tp.IsDeleted =1 

UNION
---TEACHER

SELECT CONCAT(
            COALESCE(T.FirstName + ' ', '')
            , COALESCE(T.MiddleName + ' ', '')
            , COALESCE(T.LastName,'')
        ) AS FullName,
		a.AcademicYearName,
		r.RoleKey AS UserType,
CASE WHEN tp.IsDeleted = 1 THEN tp.PaidAmount * -1 ELSE tp.PaidAmount END AS PaymentAmount,
tp.InvoiceNumber,tp.OnlineTransactionDateTime AS TransactionDate,
CASE WHEN tp.PaymentTypeId = 1 THEN 'Cash'
 WHEN tp.PaymentTypeId = 2 THEN 'Cheque'
 WHEN tp.PaymentTypeId = 3 THEN 'DD'
 WHEN tp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
 WHEN tp.PaymentTypeId = 5 THEN 'NetBanking'
 WHEN tp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentMode,

CASE WHEN (tp.PaymentTypeId = 2 OR tp.PaymentTypeId =3 )AND tp.IsChequeClear = 0 THEN tp.PaidAmount ELSE 0.00 END AS ChequeUnclearedAmount,
tp.OnlineTransactionId AS TransactionId,
u.Fname + ' '+ u.Lname AS TransactionBy,
tp.ChequeNumber,tp.ChequeDate, tp.ChequeBank

	FROM 
	TransportFeePayment tp
	INNER JOIN Teacher T
    ON tp.ConsumerId = T.TeacherId AND tp.RoleId = 3
	INNER JOIN [Role] r
	ON tp.RoleId = r.RoleId
	INNER JOIN [User] u
	ON tp.CreatedBy = u.UserId
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = tp.AcademicYearId


WHERE  CAST(tp.OnlineTransactionDateTime AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE) AND tp.IsDeleted =1

UNION

---CLERK
SELECT CONCAT(
            COALESCE(T.FirstName + ' ', '')
            , COALESCE(T.MiddleName + ' ', '')
            , COALESCE(T.LastName,'')
        ) AS FullName,
		a.AcademicYearName,
		r.RoleKey AS UserType,
CASE WHEN tp.IsDeleted = 1 THEN tp.PaidAmount * -1 ELSE tp.PaidAmount END AS PaymentAmount,
tp.InvoiceNumber,tp.OnlineTransactionDateTime AS TransactionDate,
CASE WHEN tp.PaymentTypeId = 1 THEN 'Cash'
 WHEN tp.PaymentTypeId = 2 THEN 'Cheque'
 WHEN tp.PaymentTypeId = 3 THEN 'DD'
 WHEN tp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
 WHEN tp.PaymentTypeId = 5 THEN 'NetBanking'
 WHEN tp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentMode,

CASE WHEN (tp.PaymentTypeId = 2 OR tp.PaymentTypeId =3 ) AND tp.IsChequeClear = 0 THEN tp.PaidAmount ELSE 0.00 END AS ChequeUnclearedAmount,
tp.OnlineTransactionId AS TransactionId,
u.Fname + ' '+ u.Lname AS TransactionBy,
tp.ChequeNumber,tp.ChequeDate, tp.ChequeBank

FROM 
	TransportFeePayment tp
	INNER JOIN Clerk T
    ON tp.ConsumerId = T.ClerkId  AND tp.RoleId = 4
	INNER JOIN [Role] r
	ON tp.RoleId = r.RoleId
	INNER JOIN [User] u
	ON tp.CreatedBy = u.UserId
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = tp.AcademicYearId
WHERE  CAST(tp.OnlineTransactionDateTime AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE) AND tp.IsDeleted =1



UNION 
---CAB DRIVER

SELECT CONCAT(
            COALESCE(T.FirstName + ' ', '')
            , COALESCE(T.MiddleName + ' ', '')
            , COALESCE(T.LastName,'')
        ) AS FullName,
		a.AcademicYearName,
		r.RoleKey AS UserType,
CASE WHEN tp.IsDeleted = 1 THEN tp.PaidAmount * -1 ELSE tp.PaidAmount END AS PaymentAmount,
tp.InvoiceNumber,tp.OnlineTransactionDateTime AS TransactionDate,
CASE WHEN tp.PaymentTypeId = 1 THEN 'Cash'
 WHEN tp.PaymentTypeId = 2 THEN 'Cheque'
 WHEN tp.PaymentTypeId = 3 THEN 'DD'
 WHEN tp.PaymentTypeId = 4 THEN 'Credit/Debit Card'
 WHEN tp.PaymentTypeId = 5 THEN 'NetBanking'
 WHEN tp.PaymentTypeId = 6 THEN 'UPI Payment' END AS PaymentMode,

CASE WHEN (tp.PaymentTypeId = 2 OR tp.PaymentTypeId =3 ) AND tp.IsChequeClear = 0 THEN tp.PaidAmount ELSE 0.00 END AS ChequeUnclearedAmount,
tp.OnlineTransactionId AS TransactionId,
u.Fname + ' '+ u.Lname AS TransactionBy,
tp.ChequeNumber,tp.ChequeDate, tp.ChequeBank

FROM 
	TransportFeePayment tp
	INNER JOIN CabDriver T
    ON tp.ConsumerId = T.CabDriverId  AND tp.RoleId = 6
	INNER JOIN [Role] r
	ON tp.RoleId = r.RoleId
	INNER JOIN [User] u
	ON tp.CreatedBy = u.UserId
	INNER JOIN AcademicYear a
	ON a.AcademicYearId = tp.AcademicYearId

WHERE  CAST(tp.OnlineTransactionDateTime AS DATE) BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE) AND tp.IsDeleted = 1

--Cash
SELECT * FROM @TempTransportPaymentReportDaywise WHERE  PaymentMode ='Cash'  ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempTransportPaymentReportDaywise where PaymentMode ='Cash'

--Cheque
SELECT * FROM @TempTransportPaymentReportDaywise WHERE  PaymentMode ='Cheque'  ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempTransportPaymentReportDaywise where PaymentMode ='Cheque'

--DD
SELECT * FROM @TempTransportPaymentReportDaywise WHERE  PaymentMode ='DD'  ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempTransportPaymentReportDaywise where PaymentMode ='DD'

--Credit/Debit Card
SELECT * FROM @TempTransportPaymentReportDaywise WHERE  PaymentMode ='Credit/Debit Card'  ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempTransportPaymentReportDaywise where PaymentMode ='Credit/Debit Card'

--NetBanking 
SELECT * FROM @TempTransportPaymentReportDaywise WHERE  PaymentMode ='NetBanking'  ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempTransportPaymentReportDaywise where PaymentMode ='NetBanking'

--UPI Payment
SELECT * FROM @TempTransportPaymentReportDaywise WHERE  PaymentMode ='UPI Payment'  ORDER BY TransactionDate desc
SELECT ISNULL(SUM(PaymentAmount),0.00) AS TotalPaymentAmount, ISNULL(SUM(ChequeUnclearedAmount),0.00) AS TotalChequeUnclearedAmount FROM @TempTransportPaymentReportDaywise where PaymentMode ='UPI Payment'



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


 