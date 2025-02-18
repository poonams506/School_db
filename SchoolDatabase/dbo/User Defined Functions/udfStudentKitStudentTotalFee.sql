CREATE FUNCTION udfStudentKitStudentTotalFee (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN

          DECLARE @TotalFee MONEY = 0;
                  SELECT @TotalFee = ISNULL(SUM(F.Amount),0)
                  FROM StudentKitFeeParticular F
                  WHERE F.AcademicYearId = @AcademicYearId AND F.GradeId = @GradeId AND F.DivisionId = @DivisionId AND ISNULL(F.IsPublished,0) = 1 AND F.IsDeleted <> 1 
         
		  RETURN @TotalFee

END;