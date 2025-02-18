CREATE FUNCTION udfStudentOtherPaidAmount (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN
    --      DECLARE @TotalFee MONEY;
    --      SELECT @TotalFee = ISNULL(SUM(feeDetailWithOther.PaidAmount),0)
    --      FROM FeePaymentDetails feeDetailWithOther 
    --      WHERE feeDetailWithOther.StudentId = @StudentId AND feeDetailWithOther.AcademicYearId = @AcademicYearId AND 
    --      ISNULL(feeDetailWithOther.FeeParticularId,0) = 0 AND ((feeDetailWithOther.PaymentTypeId <> 2) OR (feeDetailWithOther.PaymentTypeId = 2 AND ISNULL(feeDetailWithOther.IsChequeClear,0) = 1)) AND 
    --      feeDetailWithOther.IsDeleted <> 1 -- 2 for chequ
		  --RETURN @TotalFee

          DECLARE @TotalFee MONEY;
          SELECT @TotalFee = ISNULL(SUM(feeDetailWithOther.PaidAmount),0)
          FROM FeePaymentDetails feeDetailWithOther 
          WHERE feeDetailWithOther.StudentId = @StudentId AND feeDetailWithOther.AcademicYearId = @AcademicYearId AND 
          ISNULL(feeDetailWithOther.FeeParticularId,0) = 0 AND  
          feeDetailWithOther.IsDeleted <> 1 
		  RETURN @TotalFee
END;