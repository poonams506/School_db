CREATE FUNCTION udfStudentKitStudentDiscountedFee (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN

		  DECLARE @AddnDiscFee MONEY = 0;
          
		  SELECT @AddnDiscFee = 
             ISNULL(SUM(feeAddnDisc.AdditionalDiscountedAmount),0)
          FROM 
            StudentKitFeeAdditionalDiscount feeAddnDisc
          WHERE feeAddnDisc.AcademicYearId = @AcademicYearId AND feeAddnDisc.StudentId = @StudentId AND feeAddnDisc.IsDeleted <> 1 
		  RETURN @AddnDiscFee

END;