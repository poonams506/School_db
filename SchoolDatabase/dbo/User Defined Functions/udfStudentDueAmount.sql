CREATE FUNCTION udfStudentDueAmount (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN
          DECLARE @TotalFee MONEY;
          SELECT @TotalFee = ISNULL(dbo.udfStudentTotalFee(@GradeId,@DivisionId,@AcademicYearId,@StudentId)
            - dbo.udfStudentDiscountedFee(@GradeId,@DivisionId,@AcademicYearId,@StudentId)
            - dbo.udfStudentPaidAmount(@GradeId,@DivisionId,@AcademicYearId,@StudentId),0)
          FROM FeeParticular F
		  RETURN @TotalFee

END;