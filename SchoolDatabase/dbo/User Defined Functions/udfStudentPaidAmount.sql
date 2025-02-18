CREATE FUNCTION udfStudentPaidAmount (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN
          
          DECLARE @IsRteStudent BIT;
          SET @IsRteStudent = (SELECT IsRTEStudent FROM StudentGradeDivisionMapping WHERE StudentId = @StudentId AND AcademicYearId = @AcademicYearId AND IsDeleted <>1);

          DECLARE @TotalFee MONEY = 0;
          DECLARE @TotalFeeWithOutRTE MONEY = 0;
          IF @IsRteStudent = 1
          BEGIN
                    SELECT @TotalFee = ISNULL(SUM(feeDetail.PaidAmount),0)
                    FROM FeeParticular F
		            INNER JOIN FeePaymentDetails feeDetail 
                    ON feeDetail.StudentId = @StudentId AND feeDetail.AcademicYearId = @AcademicYearId AND 
                    feeDetail.FeeParticularId > 0 
                    AND feeDetail.IsDeleted <> 1 -- 2 
		            AND feeDetail.FeeParticularId = F.FeeParticularId
                    WHERE F.AcademicYearId = @AcademicYearId AND F.GradeId = @GradeId AND F.DivisionId = @DivisionId AND ISNULL(F.IsPublished,0) = 1 AND F.IsDeleted <> 1 
                    AND feeDetail.IsDeleted <> 1 
                    AND F.IsRTEApplicable = 1
          END
          ELSE
          BEGIN
                    SELECT @TotalFeeWithOutRTE = ISNULL(SUM(feeDetail.PaidAmount),0)
                    FROM FeeParticular F
		            INNER JOIN FeePaymentDetails feeDetail 
                    ON feeDetail.StudentId = @StudentId AND feeDetail.AcademicYearId = @AcademicYearId AND 
                    feeDetail.FeeParticularId > 0 
                    AND feeDetail.IsDeleted <> 1 -- 2 
		            AND feeDetail.FeeParticularId = F.FeeParticularId
                    WHERE F.AcademicYearId = @AcademicYearId AND F.GradeId = @GradeId AND F.DivisionId = @DivisionId AND ISNULL(F.IsPublished,0) = 1 AND F.IsDeleted <> 1 
                    AND feeDetail.IsDeleted <> 1 
          END

          
		  RETURN @TotalFee + @TotalFeeWithOutRTE

END;