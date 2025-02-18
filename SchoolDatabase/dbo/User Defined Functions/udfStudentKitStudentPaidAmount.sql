CREATE FUNCTION udfStudentKitStudentPaidAmount (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN
          

          DECLARE @TotalFee MONEY = 0;
                    SELECT @TotalFee = ISNULL(SUM(feeDetail.PaidAmount),0)
                    FROM StudentKitFeeParticular F
		            INNER JOIN StudentKitFeePaymentDetails feeDetail 
                    ON feeDetail.StudentId = @StudentId AND feeDetail.AcademicYearId = @AcademicYearId AND 
                    feeDetail.FeeParticularId > 0 
                    AND feeDetail.IsDeleted <> 1 -- 2 
		            AND feeDetail.FeeParticularId = F.FeeParticularId
                    WHERE F.AcademicYearId = @AcademicYearId AND F.GradeId = @GradeId AND F.DivisionId = @DivisionId AND ISNULL(F.IsPublished,0) = 1 AND F.IsDeleted <> 1 
                    AND feeDetail.IsDeleted <> 1 

          
		  RETURN @TotalFee

END;