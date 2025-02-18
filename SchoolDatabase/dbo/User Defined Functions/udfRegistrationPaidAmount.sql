CREATE FUNCTION [dbo].[udfRegistrationPaidAmount] (@AcademicYearId SMALLINT, @StudentEnquiryId BIGINT)
RETURNS MONEY AS
BEGIN
          
          DECLARE @TotalFee MONEY = 0;
                    SELECT @TotalFee = ISNULL(SUM(feeDetail.PaidAmount),0)
                    FROM RegistrationFee F
		            INNER JOIN RegistrationFeeDetails feeDetail 
                    ON feeDetail.StudentEnquiryId = @StudentEnquiryId AND feeDetail.AcademicYearId = @AcademicYearId AND 
                    feeDetail.FeeParticularId > 0 
                    AND feeDetail.IsDeleted <> 1 -- 2 
		            AND feeDetail.RegistrationFeeId = F.RegistrationFeeId
                    WHERE F.AcademicYearId = @AcademicYearId  AND F.IsDeleted <> 1 
                    AND feeDetail.IsDeleted <> 1 
		  RETURN @TotalFee 

END;