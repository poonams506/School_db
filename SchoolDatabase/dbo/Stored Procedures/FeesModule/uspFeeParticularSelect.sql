-- =============================================
-- Author:    Shambala Apugade
-- Create date: 27/08/2023
-- Description:  This stored procedure is used to get Fee Particular info detail by Id
-- =============================================
CREATE PROCEDURE uspFeeParticularSelect
(
@ClassId INT,
@AcademicYearId SMALLINT
)
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

DECLARE @GradeId SMALLINT;
DECLARE @DivisionId SMALLINT;

SELECT TOP (1) @GradeId=GradeId,@DivisionId=DivisionId
FROM dbo.SchoolGradeDivisionMatrix sgdm
WHERE SchoolGradeDivisionMatrixId=@ClassId
ORDER BY CreatedDate DESC;

SELECT g.GradeName,g.GradeId,d.DivisionName,
       d.DivisionId,sgdm.SchoolGradeDivisionMatrixId AS ClassId,
       CONCAT(g.GradeName,'-', d.DivisionName) AS ClassName
FROM dbo.SchoolGradeDivisionMatrix sgdm
JOIN dbo.Grade g ON sgdm.GradeId=g.GradeId
JOIN dbo.Division d ON sgdm.DivisionId=d.DivisionId
WHERE sgdm.SchoolGradeDivisionMatrixId=@ClassId AND sgdm.AcademicYearId = @AcademicYearId;

-- FeeParticular list
SELECT
    f.FeeParticularId,
    sgdm.SchoolGradeDivisionMatrixId AS ClassId,
    f.ParticularName,
    f.Amount,
    f.IsDiscountApplicable,
    f.IsRTEApplicable,
    f.IsPublished AS IsPublish,
    f.SortBy,
    CASE WHEN fp.FeePaymentDetailId IS NULL THEN 0
         ELSE 1 END AS IsFeePaymentAlreadyDone 

FROM
     dbo.FeeParticular f
     OUTER APPLY (SELECT TOP (1) fp.FeePaymentDetailId FROM dbo.FeePaymentDetails fp WHERE
                    fp.FeeParticularId=f.FeeParticularId AND fp.AcademicYearId=@AcademicYearId
                    AND fp.IsDeleted<>1 ORDER BY fp.FeePaymentDetailId) AS fp
     
     INNER JOIN dbo.Grade g ON f.GradeId = g.GradeId
     INNER JOIN dbo.Division d ON f.DivisionId = d.DivisionId
	 INNER JOIN dbo.SchoolGradeDivisionMatrix sgdm ON g.GradeId = sgdm.GradeId AND d.DivisionId = sgdm.DivisionId AND f.AcademicYearId = sgdm.AcademicYearId
    
WHERE
     sgdm.SchoolGradeDivisionMatrixId = @ClassId 
     AND f.IsDeleted<>1
     AND f.AcademicYearId = @AcademicYearId

-- FeeParticularWavierMapping list
SELECT
    CASE WHEN f.FeeParticularWavierMappingId IS NULL THEN 0 ELSE f.FeeParticularWavierMappingId END AS FeeParticularWavierMappingId,
    fw.FeeWavierTypeId,
    fw.FeeWavierTypeName,
    fw.FeeWavierDisplayName,
    fw.NumberOfInstallments,
    ROUND(fw.DiscountInPercent*100,2) AS DiscountInPercent,
    ROUND(fw.LatePerDayFeeInPercent*100,2) AS LatePerDayFeeInPercent,
    CASE WHEN f.FeeParticularWavierMappingId IS NULL THEN 0
         ELSE 1 END AS IsAlreadyAdded,
    ISNULL(f.SortBy,0) AS SortBy,
    CASE WHEN fpw.FeePaymentAppliedWavierMappingId IS NULL THEN 0
         ELSE 1 END AS IsFeePaymentAlreadyDone,
         (SELECT Min(fd.LateFeeStartDate) 
                FROM dbo.FeeWavierTypesInstallmentsDetails fd 
                WHERE fd.FeeWavierTypeId = fw.FeeWavierTypeId 
                AND fd.IsDeleted <> 1) AS LateFeeStartDate,
     (SELECT Max(fd.DiscountEndDate) 
             FROM dbo.FeeWavierTypesInstallmentsDetails fd 
             WHERE fd.FeeWavierTypeId = fw.FeeWavierTypeId 
             AND fd.IsDeleted <> 1) AS DiscountEndDate
FROM
     dbo.FeeWavierTypes fw 
     LEFT JOIN dbo.FeeParticularWavierMapping f ON 
                (f.FeeWavierTypeId=fw.FeeWavierTypeId 
                AND f.GradeId = @GradeId 
                AND f.DivisionId = @DivisionId
                AND f.IsDeleted<>1
                AND f.AcademicYearId = @AcademicYearId)
     OUTER APPLY (SELECT TOP (1) fpw.FeePaymentAppliedWavierMappingId FROM dbo.FeePaymentAppliedWavierMapping fpw 
                   WHERE fpw.FeeParticularWavierMappingId=f.FeeParticularWavierMappingId AND
                   fpw.AcademicYearId=@AcademicYearId AND fpw.IsDeleted<>1 ORDER BY fpw.FeePaymentAppliedWavierMappingId) as fpw
WHERE
     fw.AcademicYearId= @AcademicYearId
     AND fw.IsActive=1
     AND fw.IsDeleted<>1;
    
SELECT F.DiscountEndDate,
F.LateFeeStartDate,
F.FeeWavierTypeId,
ROW_NUMBER() OVER(partition by F.FeeWavierTypeId order by F.FeeWavierTypesInstallmentsDetailsId, F.FeeWavierTypeId asc) AS InstallmentNumber
FROM
dbo.FeeWavierTypesInstallmentsDetails F
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





