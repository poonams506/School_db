-- =============================================
-- Author:    Meena Kotkar
-- Create date: 09/09/2024  
-- Description:  This stored procedure is used to get registration Fee Payment history info detail by payment fee Id
-- =============================================
CREATE PROCEDURE [dbo].[uspRegistrationHistorySelect]
	@AcademicYearId SMALLINT,
	@StudentEnquiryId BIGINT,
	@RegistrationFeeId INT
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
        DECLARE @FeePaymentTypeTable TABLE(
		   PaymentTypeId TINYINT,
		   PaymentTypeName NVARCHAR(50)
		  )
        INSERT INTO @FeePaymentTypeTable(PaymentTypeId, PaymentTypeName) VALUES (1,'Cash'),(2,'Cheque'),(3,'DD'),(4,'Credit/Debit Card'),(5,'Net Banking'),(6,'UPI Payment');
        
		-- 1st result for student info
        SELECT 
		s.StudentEnquiryId,
		s.StudentFirstName + ' ' + s.StudentMiddleName + ' ' + s.StudentLastName AS 'StudentName',
		s.AcademicYearId,
        (SELECT SchoolName FROM School) AS SchoolName,
		(SELECT ISNULL(SchoolAddressLine1,'') + IIF(SchoolAddressLine1 IS NULL,'',', ') + ISNULL(SchoolAddressLine2,'') + IIF(SchoolAddressLine2 IS NULL,'',', ') + TalukaName + ', ' + DistrictName + ', ' + StateName + ', ' + Pincode  FROM School) AS SchoolAddress,
		r.OnlineTransactionId AS TransactionId,
		r.RegistrationInvoiceNumber,
		t.PaymentTypeName,
		g.GradeName,d.DivisionName,
		r.OnlineTransactionDateTime AS PaymentDate
		FROM StudentEnquiry s
		INNER JOIN SchoolGradeDivisionMatrix m ON s.InterestedClassId=m.SchoolGradeDivisionMatrixId
		INNER JOIN Grade g ON m.GradeId=g.GradeId
		INNER JOIN Division d ON m.DivisionId=d.DivisionId
		INNER JOIN RegistrationFee r
		ON r.StudentEnquiryId = s.StudentEnquiryId AND r.AcademicYearId = @AcademicYearId AND r.RegistrationFeeId = @RegistrationFeeId
		INNER JOIN @FeePaymentTypeTable t
        ON r.PaymentTypeId = t.PaymentTypeId 
		WHERE ISNULL(s.IsDeleted,0) <> 1
		AND s.IsDeleted <> 1
		AND ISNULL(r.IsDeleted,0) <> 1
		AND s.AcademicYearId = @AcademicYearId
		AND r.StudentEnquiryId = @StudentEnquiryId;
		with cte as(
		SELECT DISTINCT
		r.FeeParticularId,
		f.Particular AS 'ParticularName',
		r.PaidAmount AS 'TotalFee'
		FROM 
		 RegistrationFeeDetails r 
		INNER JOIN AdhocParticularMaster f ON f.AdhocParticularMasterId=r.FeeParticularId
		INNER JOIN RegistrationFee s
		ON r.StudentEnquiryId = s.StudentEnquiryId
		WHERE 
		ISNULL(f.IsDeleted,0) <> 1
		AND ISNULL(s.IsDeleted,0) <> 1
		AND r.AcademicYearId = @AcademicYearId
		AND r.StudentEnquiryId = @StudentEnquiryId
		AND r.RegistrationFeeId = @RegistrationFeeId
		
		)

		SELECT * FROM cte 
		
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