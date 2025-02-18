-- =============================================
-- Author:    Deepak Walunj
-- Create date: 08/09/2023
-- Description:  This stored procedure is used to get Avail Waiver Discount Mapping listing for academic fee payment page
-- =============================================
CREATE PROCEDURE uspFeeParticularWavierMappingSelect(@GradeId SMALLINT,
@DivisionId SMALLINT,
@AcademicYearId SMALLINT,
@StudentId BIGINT)
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

DECLARE @CurrentInstallment INT = 0;
SELECT @CurrentInstallment = Count(FeePaymentId) + 1 FROM FeePayment
		WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1 AND StudentId = @StudentId AND GradeId = @GradeId AND DivisionId = @DivisionId

DECLARE @DiscountDateTable TABLE(
InstallmentNumber INT,
DiscountEndDate DATETIME,
FeeWavierTypeId BIGINT,
FeeWavierTypesInstallmentsDetailsId BIGINT,
FeeWavierDisplayName NVARCHAR(200)
)
INSERT INTO @DiscountDateTable
SELECT
  ROW_NUMBER() OVER(partition by d.FeeWavierTypeId order by d.FeeWavierTypesInstallmentsDetailsId, d.FeeWavierTypeId asc) AS InstallmentNumber,
  d.DiscountEndDate,
  d.FeeWavierTypeId,
  d.FeeWavierTypesInstallmentsDetailsId,
  fwt.FeeWavierDisplayName
FROM
     FeeParticularWavierMapping f
     INNER JOIN FeeWavierTypes fwt
     ON f.AcademicYearId = fwt.AcademicYearId AND f.FeeWavierTypeId = fwt.FeeWavierTypeId
     INNER JOIN FeeWavierTypesInstallmentsDetails d
     ON fwt.FeeWavierTypeId = d.FeeWavierTypeId and fwt.AcademicYearId = @AcademicYearId and d.AcademicYearId = @AcademicYearId
WHERE ISNULL(f.IsDeleted,0) <> 1
     AND ISNULL(fwt.IsDeleted,0) <> 1
     AND d.IsDeleted <> 1
     AND fwt.IsActive = 1
     AND f.GradeId = @GradeId 
     AND f.DivisionId = @DivisionId
     AND f.AcademicYearId = @AcademicYearId



DECLARE @TotalFee MONEY = 0;
DECLARE @TotalFeeWithRTE MONEY = 0;
DECLARE @TotalFeeWithOutRTE MONEY =0;

DECLARE @TotalFeeDiscountApplicable MONEY = 0;
DECLARE @TotalFeeWithRTEDiscountApplicable MONEY = 0;
DECLARE @TotalFeeWithOutRTEDiscountApplicable MONEY =0;

SELECT @TotalFeeWithOutRTE = ISNULL(SUM(f.Amount),0) FROM FeeParticular f
		INNER JOIN StudentGradeDivisionMapping m
		ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
		INNER JOIN Student s
		ON m.StudentId = s.StudentId
        WHERE 
		ISNULL(f.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(s.IsDeleted,0) <> 1
        AND ISNULL(s.IsArchive,0) <> 1
		AND f.AcademicYearId = @AcademicYearId
		AND m.AcademicYearId = @AcademicYearId
        AND m.GradeId = @GradeId
        AND m.DivisionId = @DivisionId
		AND ISNULL(F.IsPublished,0) = 1
        AND s.StudentId = @StudentId
        AND m.IsRTEStudent <> 1

SELECT @TotalFeeWithRTE = ISNULL(SUM(f.Amount),0) FROM FeeParticular f
		INNER JOIN StudentGradeDivisionMapping m
		ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
		INNER JOIN Student s
		ON m.StudentId = s.StudentId
        WHERE 
		ISNULL(f.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(s.IsDeleted,0) <> 1
        AND ISNULL(s.IsArchive,0) <> 1
		AND f.AcademicYearId = @AcademicYearId
		AND m.AcademicYearId = @AcademicYearId
        AND m.GradeId = @GradeId
        AND m.DivisionId = @DivisionId
		AND ISNULL(F.IsPublished,0) = 1
        AND s.StudentId = @StudentId
        AND m.IsRTEStudent = 1
        AND f.IsRTEApplicable = 1

SET @TotalFee = @TotalFeeWithRTE + @TotalFeeWithOutRTE;

SELECT @TotalFeeWithOutRTEDiscountApplicable = ISNULL(SUM(f.Amount),0) FROM FeeParticular f
		INNER JOIN StudentGradeDivisionMapping m
		ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
		INNER JOIN Student s
		ON m.StudentId = s.StudentId
        WHERE 
		ISNULL(f.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(s.IsDeleted,0) <> 1
        AND ISNULL(s.IsArchive,0) <> 1
		AND f.AcademicYearId = @AcademicYearId
		AND m.AcademicYearId = @AcademicYearId
        AND m.GradeId = @GradeId
        AND m.DivisionId = @DivisionId
		AND ISNULL(F.IsPublished,0) = 1
        AND s.StudentId = @StudentId
        AND m.IsRTEStudent <> 1
        AND F.IsDiscountApplicable = 1

SELECT @TotalFeeWithRTEDiscountApplicable = ISNULL(SUM(f.Amount),0) FROM FeeParticular f
		INNER JOIN StudentGradeDivisionMapping m
		ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
		INNER JOIN Student s
		ON m.StudentId = s.StudentId
        WHERE 
		ISNULL(f.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(s.IsDeleted,0) <> 1
        AND ISNULL(s.IsArchive,0) <> 1
		AND f.AcademicYearId = @AcademicYearId
		AND m.AcademicYearId = @AcademicYearId
        AND m.GradeId = @GradeId
        AND m.DivisionId = @DivisionId
		AND ISNULL(F.IsPublished,0) = 1
        AND s.StudentId = @StudentId
        AND m.IsRTEStudent = 1
        AND f.IsRTEApplicable = 1
        AND F.IsDiscountApplicable = 1

SET @TotalFeeDiscountApplicable = @TotalFeeWithRTEDiscountApplicable + @TotalFeeWithOutRTEDiscountApplicable;

SELECT @TotalFee AS TotalFee

-- FeeParticularWavierMapping list
SELECT
    @TotalFee AS TotalFee,
    f.FeeParticularWavierMappingId,
    f.GradeId,
    f.DivisionId,
    f.FeeWavierTypeId,
    f.SortBy,
    fwt.FeeWavierDisplayName,
    fwt.FeeWavierTypeName,
    fwt.DiscountInPercent * 100 AS DiscountInPercent,
    fwt.LatePerDayFeeInPercent * 100 AS LatePerDayFeeInPercent,
    fwt.NumberOfInstallments,
    @TotalFee - ISNULL(@TotalFeeDiscountApplicable * fwt.DiscountInPercent,0) AS 'ApplicableFee',
    (SELECT Min(fd.LateFeeStartDate) FROM FeeWavierTypesInstallmentsDetails fd WHERE fd.FeeWavierTypeId = fwt.FeeWavierTypeId AND fd.IsDeleted <> 1) AS LateFeeStartDate,
    (SELECT DiscountEndDate FROM @DiscountDateTable WHERE FeeWavierTypeId = fwt.FeeWavierTypeId AND InstallmentNumber = @CurrentInstallment) AS DiscountEndDate
FROM
     FeeParticularWavierMapping f
     INNER JOIN FeeWavierTypes fwt
     ON f.AcademicYearId = fwt.AcademicYearId AND f.FeeWavierTypeId = fwt.FeeWavierTypeId
WHERE ISNULL(f.IsDeleted,0) <> 1
     AND ISNULL(fwt.IsDeleted,0) <> 1
     AND fwt.IsActive = 1
     AND f.GradeId = @GradeId 
     AND f.DivisionId = @DivisionId
     AND f.AcademicYearId = @AcademicYearId
     --AND CAST(fwt.StartDate AS DATE) <= CAST(GETDATE() AS DATE)
     --AND CAST(fwt.EndDate AS DATE)  >= CAST(GETDATE() AS DATE)

SELECT * FROM @DiscountDateTable

SELECT F.DiscountEndDate,
F.LateFeeStartDate,
F.FeeWavierTypeId,
ROW_NUMBER() OVER(partition by F.FeeWavierTypeId order by F.FeeWavierTypesInstallmentsDetailsId, F.FeeWavierTypeId asc) AS InstallmentNumber
FROM
FeeWavierTypesInstallmentsDetails F
WHERE F.IsDeleted <> 1
AND F.AcademicYearId = @AcademicYearId




END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
DECLARE @ErrorState INT = ERROR_STATE();
DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();
DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
EXEC uspExceptionLogInsert @ErrorLine, 
@ErrorMessage, 
@ErrorNumber, 
@ErrorProcedure, 
@ErrorSeverity, 
@ErrorState END CATCH End





