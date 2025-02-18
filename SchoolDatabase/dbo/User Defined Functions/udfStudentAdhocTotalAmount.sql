CREATE FUNCTION udfStudentAdhocTotalAmount (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN
          
           DECLARE @TotalFee MONEY = 0;
         
           SELECT @TotalFee = ISNULL(SUM(F.TotalFee),0)
                    FROM AdhocFeePayment F 
                    WHERE F.AcademicYearId = @AcademicYearId AND F.GradeId = @GradeId AND F.DivisionId = @DivisionId
                    AND F.IsDeleted <> 1 
                    AND F.StudentId = @StudentId

          RETURN @TotalFee

END;