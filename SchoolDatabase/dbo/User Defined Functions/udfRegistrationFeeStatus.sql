CREATE FUNCTION [dbo].[udfRegistrationFeeStatus] (@AcademicYearId SMALLINT, @StudentEnquiryId BIGINT)
RETURNS INT AS
BEGIN
          DECLARE @FeePaymentCount INT=0;
    SELECT @FeePaymentCount = COUNT(a.RegistrationFeeId) 
    FROM RegistrationFee a
    WHERE  a.AcademicYearId = @AcademicYearId AND  a.StudentEnquiryId=@StudentEnquiryId AND a.IsDeleted <> 1;
		RETURN @FeePaymentCount ;
END;