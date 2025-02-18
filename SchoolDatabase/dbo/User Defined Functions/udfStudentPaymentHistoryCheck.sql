CREATE FUNCTION udfStudentPaymentHistoryCheck (@AcademicYearId SMALLINT, @StudentId BIGINT)
RETURNS BIT AS
BEGIN

     DECLARE @PaymentExist INT;
    DECLARE @FeePaymentCount INT;
	SET @PaymentExist=0;
    SELECT @FeePaymentCount = COUNT(a.AdhocFeePaymentId) 
    FROM AdhocFeePayment a
    WHERE  a.AcademicYearId = @AcademicYearId AND  a.StudentId=@StudentId AND a.IsDeleted <> 1;

    IF @FeePaymentCount<1
    BEGIN 
            SELECT @FeePaymentCount =@FeePaymentCount+ COUNT(f.FeePaymentId) 
            FROM FeePayment f
            WHERE  f.AcademicYearId = @AcademicYearId AND  f.StudentId=@StudentId AND  f.IsDeleted <> 1;

            SELECT @FeePaymentCount =@FeePaymentCount+ COUNT(tf.TransportFeePaymentId) 
            FROM TransportFeePayment tf
            WHERE  tf.AcademicYearId = @AcademicYearId AND  tf.ConsumerId=@StudentId AND  tf.RoleId=5 AND tf.IsDeleted <> 1;

            SELECT @FeePaymentCount =@FeePaymentCount+ COUNT(st.StudentKitFeePaymentId) 
            FROM StudentKitFeePayment st
            WHERE  st.AcademicYearId = @AcademicYearId AND  st.StudentId=@StudentId  AND st.IsDeleted <> 1;
   
    END
    IF @FeePaymentCount > 0
    BEGIN
        SET @PaymentExist = 1;  
    END
     RETURN @PaymentExist;

END;