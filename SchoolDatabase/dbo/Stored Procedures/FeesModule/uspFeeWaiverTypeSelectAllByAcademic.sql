-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 09/09/2023
-- Description:  This stored procedure is used to  get FeeWavierType info detail by Academic year
-- =============================================

CREATE PROCEDURE uspFeeWaiverTypeSelectAllByAcademic
(
 @AcademicYearId SMALLINT
) 
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT
   F.FeeWavierTypeId,
   F.FeeWavierTypeName, 
   F.FeeWavierDisplayName, 
   F.IsActive,
   F.NumberOfInstallments,
   F.DiscountInPercent*100 AS DiscountInPercent,
   F.LatePerDayFeeInPercent*100 AS LatePerDayFeeInPercent,
     (SELECT Min(fd.LateFeeStartDate) FROM FeeWavierTypesInstallmentsDetails fd WHERE fd.FeeWavierTypeId = F.FeeWavierTypeId AND fd.IsDeleted <> 1) AS LateFeeStartDate,
     (SELECT Max(fd.DiscountEndDate) FROM FeeWavierTypesInstallmentsDetails fd WHERE fd.FeeWavierTypeId = F.FeeWavierTypeId AND fd.IsDeleted <> 1) AS DiscountEndDate
FROM 
   dbo.FeeWavierTypes F
WHERE 
       F.AcademicYearId =  @AcademicYearId 
   AND F.IsActive=1
   AND F.IsDeleted <> 1

SELECT F.DiscountEndDate,
F.LateFeeStartDate,
F.FeeWavierTypeId,
ROW_NUMBER() OVER(partition by F.FeeWavierTypeId order by F.FeeWavierTypesInstallmentsDetailsId, F.FeeWavierTypeId asc) AS InstallmentNumber
FROM
FeeWavierTypesInstallmentsDetails F
WHERE F.IsDeleted <> 1
AND F.AcademicYearId = @AcademicYearId


END TRY
BEGIN CATCH 

DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
DECLARE @ErrorState INT = ERROR_STATE();
DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();
DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();

EXEC dbo.uspExceptionLogInsert @ErrorLine=@ErrorLine, 
@ErrorMessage=@ErrorMessage, 
@ErrorNumber=@ErrorNumber, 
@ErrorProcedure=@ErrorProcedure, 
@ErrorSeverity=@ErrorSeverity, 
@ErrorState=@ErrorState 

END CATCH

END

