CREATE FUNCTION udfStudentAdhocChequeClearedAmount (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN
          DECLARE @TotalFee MONEY;
          SELECT @TotalFee = ISNULL(SUM(feeDetailChequeCleared.TotalFee),0)
          FROM  AdhocFeePayment feeDetailChequeCleared
          WHERE feeDetailChequeCleared.StudentId = @StudentId AND feeDetailChequeCleared.AcademicYearId = @AcademicYearId AND  
          (feeDetailChequeCleared.PaymentTypeId = 2 OR feeDetailChequeCleared.PaymentTypeId = 3) AND ISNULL(feeDetailChequeCleared.IsChequeClear,0) = 1
          AND feeDetailChequeCleared.IsDeleted <> 1 AND feeDetailChequeCleared.GradeId = @GradeId AND feeDetailChequeCleared.DivisionId = @DivisionId
		  RETURN @TotalFee

END;