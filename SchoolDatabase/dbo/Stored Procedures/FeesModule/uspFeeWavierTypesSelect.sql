-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 25/09/2023
-- Description:  This stored procedure is used to  get FeeWavierType info detail by Id
-- =============================================

CREATE PROCEDURE uspFeeWavierTypeSelect
(
 @FeeWavierTypeId BIGINT,
 @AcademicYearId SMALLINT
) 
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT
   FeeWavierTypeId,
   AcademicYearId,
   FeeWavierTypeName, 
   FeeWavierDisplayName, 
   [Description], 
   CategoryId, 
   NumberOfInstallments,
   ROUND(DiscountInPercent*100,2) AS DiscountInPercent,
   ROUND(LatePerDayFeeInPercent*100,2) AS LatePerDayFeeInPercent,
   IsActive,
   (SELECT Min(fd.LateFeeStartDate) FROM FeeWavierTypesInstallmentsDetails fd WHERE fd.FeeWavierTypeId = @FeeWavierTypeId AND fd.IsDeleted <> 1) AS LateFeeStartDate,
   (SELECT Max(fd.DiscountEndDate) FROM FeeWavierTypesInstallmentsDetails fd WHERE fd.FeeWavierTypeId = @FeeWavierTypeId AND fd.IsDeleted <> 1) AS DiscountEndDate
FROM 
   FeeWavierTypes
WHERE 
   FeeWavierTypeId  = @FeeWavierTypeId 
   AND AcademicYearId =  @AcademicYearId 
   AND IsDeleted <> 1


SELECT
LateFeeStartDate,
DiscountEndDate,
FeeWavierTypesInstallmentsDetailsId AS FeeWavierTypesInstallmentsDetailsTypeId
FROM FeeWavierTypesInstallmentsDetails
WHERE 
FeeWavierTypeId  = @FeeWavierTypeId 
   AND AcademicYearId =  @AcademicYearId 
   AND IsDeleted <> 1


SELECT
w.FeeWavierTypesInstallmentsDetailsId 
FROM FeeWavierTypesInstallmentsDetails w
INNER JOIN FeePayment fp
ON w.FeeWavierTypesInstallmentsDetailsId = fp.FeeWavierTypesInstallmentsDetailsId
WHERE 
w.FeeWavierTypeId  = @FeeWavierTypeId 
   AND w.AcademicYearId =  @AcademicYearId 
   AND w.IsDeleted <> 1
   AND fp.IsDeleted <> 1
   AND fp.AcademicYearId = @AcademicYearId
   


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

