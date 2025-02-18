CREATE FUNCTION udfStudentKitStudentDueAmount (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN
          DECLARE @TotalFee MONEY;
          SELECT @TotalFee = ISNULL(dbo.udfStudentKitStudentTotalFee(@GradeId,@DivisionId,@AcademicYearId,@StudentId)
            - dbo.udfStudentKitStudentDiscountedFee(@GradeId,@DivisionId,@AcademicYearId,@StudentId)
            - dbo.udfStudentKitStudentPaidAmount(@GradeId,@DivisionId,@AcademicYearId,@StudentId),0)
          FROM StudentKitFeeParticular F
		  RETURN @TotalFee

END;