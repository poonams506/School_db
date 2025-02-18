CREATE FUNCTION udfStudentKitStudentChequeUnClearAmount (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN
          DECLARE @TotalFee MONEY;
          SELECT @TotalFee = ISNULL(SUM(feeDetailChequeCleared.PaidAmount),0)
          FROM  StudentKitFeePaymentDetails feeDetailChequeCleared
          WHERE feeDetailChequeCleared.StudentId = @StudentId AND feeDetailChequeCleared.AcademicYearId = @AcademicYearId AND 
          feeDetailChequeCleared.FeeParticularId > 0 AND (feeDetailChequeCleared.PaymentTypeId = 2 OR feeDetailChequeCleared.PaymentTypeId = 3) AND ISNULL(feeDetailChequeCleared.IsChequeClear,0) = 0
          AND feeDetailChequeCleared.IsDeleted <> 1
		  RETURN @TotalFee

END;