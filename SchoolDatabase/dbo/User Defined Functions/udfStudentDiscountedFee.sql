CREATE FUNCTION udfStudentDiscountedFee (@GradeId SMALLINT, @DivisionId SMALLINT, @AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS MONEY AS
BEGIN

            
          DECLARE @DiscountedSkipCount INT;
          
          SELECT @DiscountedSkipCount = Count(FeePaymentId) FROM FeePayment
		  WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1 AND StudentId = @StudentId AND GradeId = @GradeId AND DivisionId = @DivisionId AND SkipDiscount = 1;

          DECLARE @DiscountedCount INT;
          
          SELECT @DiscountedCount = Count(FeePaymentId) FROM FeePayment
		  WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1 AND StudentId = @StudentId AND GradeId = @GradeId AND DivisionId = @DivisionId AND SkipDiscount <> 1;
          
          DECLARE @IsRteStudent BIT;
          SET @IsRteStudent = (SELECT IsRTEStudent FROM StudentGradeDivisionMapping WHERE StudentId = @StudentId AND AcademicYearId = @AcademicYearId AND IsDeleted <>1);

          DECLARE @DiscFeeWithOutRTE MONEY = 0;
          DECLARE @DiscFeeWithRTE MONEY = 0;
		  DECLARE @AddnDiscFee MONEY = 0;
          IF @IsRteStudent = 1
          BEGIN


                SELECT @DiscFeeWithRTE = --ISNULL(SUM(ISNULL(IIF(ISNULL(F.IsDiscountApplicable,0) = 1, F.Amount * (discType.DiscountInPercent), 0),0)),0)
                                       --- 
                                       ISNULL((ISNULL(SUM(ISNULL(IIF(ISNULL(F.IsDiscountApplicable,0) = 1, F.Amount * (discType.DiscountInPercent), 0),0)),0) / max(discType.NumberOfInstallments)) * @DiscountedCount,0)
                FROM FeeParticular F
		        JOIN FeePaymentAppliedWavierMapping AS disc
                ON disc.AcademicYearId = @AcademicYearId AND disc.StudentId = @StudentId  AND disc.IsDeleted <> 1
		        JOIN FeeParticularWavierMapping AS fpwp
                ON fpwp.FeeParticularWavierMappingId = disc.FeeParticularWavierMappingId AND 
                fpwp.AcademicYearId = @AcademicYearId AND fpwp.GradeId = @GradeId AND fpwp.DivisionId = @DivisionId AND fpwp.IsDeleted <> 1
		         INNER JOIN FeeWavierTypes AS discType
                 ON discType.FeeWavierTypeId = fpwp.FeeWavierTypeId AND discType.AcademicYearId = @AcademicYearId AND ISNULL(discType.IsActive,0) = 1 AND discType.IsDeleted <> 1
                WHERE F.AcademicYearId = @AcademicYearId AND F.GradeId = @GradeId AND F.DivisionId = @DivisionId AND ISNULL(F.IsPublished,0) = 1 AND F.IsDeleted <> 1 
                AND disc.IsDeleted <> 1 AND F.IsRTEApplicable = 1

          END
          ELSE
          BEGIN
                SELECT @DiscFeeWithOutRTE = --ISNULL(SUM(ISNULL(IIF(ISNULL(F.IsDiscountApplicable,0) = 1, F.Amount * (discType.DiscountInPercent), 0),0)),0)
                                          --- 
                                          ISNULL((ISNULL(SUM(ISNULL(IIF(ISNULL(F.IsDiscountApplicable,0) = 1, F.Amount * (discType.DiscountInPercent), 0),0)),0) / max(discType.NumberOfInstallments)) * @DiscountedCount,0)
                FROM FeeParticular F
		        JOIN FeePaymentAppliedWavierMapping AS disc
                ON disc.AcademicYearId = @AcademicYearId AND disc.StudentId = @StudentId  AND disc.IsDeleted <> 1
		        JOIN FeeParticularWavierMapping AS fpwp
                ON fpwp.FeeParticularWavierMappingId = disc.FeeParticularWavierMappingId AND 
                fpwp.AcademicYearId = @AcademicYearId AND fpwp.GradeId = @GradeId AND fpwp.DivisionId = @DivisionId AND fpwp.IsDeleted <> 1
		         INNER JOIN FeeWavierTypes AS discType
                 ON discType.FeeWavierTypeId = fpwp.FeeWavierTypeId AND discType.AcademicYearId = @AcademicYearId AND ISNULL(discType.IsActive,0) = 1 AND discType.IsDeleted <> 1
                WHERE F.AcademicYearId = @AcademicYearId AND F.GradeId = @GradeId AND F.DivisionId = @DivisionId AND ISNULL(F.IsPublished,0) = 1 AND F.IsDeleted <> 1 
                AND disc.IsDeleted <> 1
          END
          

          

		  SELECT @AddnDiscFee = 
             ISNULL(SUM(feeAddnDisc.AdditionalDiscountedAmount),0)
          FROM 
            FeeAdditionalDiscount feeAddnDisc
          WHERE feeAddnDisc.AcademicYearId = @AcademicYearId AND feeAddnDisc.StudentId = @StudentId AND feeAddnDisc.IsDeleted <> 1 
		  RETURN @DiscFeeWithRTE + @DiscFeeWithOutRTE + @AddnDiscFee

END;