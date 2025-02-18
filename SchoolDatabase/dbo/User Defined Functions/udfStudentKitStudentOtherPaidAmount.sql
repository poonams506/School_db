CREATE FUNCTION udfStudentKitStudentOtherPaidAmount (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN
  
          DECLARE @TotalFee MONEY;
          SELECT @TotalFee = ISNULL(SUM(feeDetailWithOther.PaidAmount),0)
          FROM StudentKitFeePaymentDetails feeDetailWithOther 
          WHERE feeDetailWithOther.StudentId = @StudentId AND feeDetailWithOther.AcademicYearId = @AcademicYearId AND 
          ISNULL(feeDetailWithOther.FeeParticularId,0) = 0 AND  
          feeDetailWithOther.IsDeleted <> 1 
		  RETURN @TotalFee
END;