-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 16/09/2023
-- Description:  This stored procedure is used to get Fee Particular info detail by Id
-- =============================================
CREATE PROCEDURE uspStudentKitFeeParticularClone
(
@AcademicYearId INT,
@FromClassId INT,
@ToClassId dbo.[SingleIdType] READONLY,
@UserId INT
)
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

   DECLARE @FromGradeId SMALLINT;
   DECLARE @FromDivisionId SMALLINT;

   SELECT 
      @FromGradeId=sgdm.GradeId,
      @FromDivisionId=sgdm.DivisionId

  FROM  
  dbo.SchoolGradeDivisionMatrix sgdm JOIN
  dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
  dbo.Division d ON sgdm.DivisionId=d.DivisionId
  WHERE sgdm.IsDeleted <> 1 AND sgdm.SchoolGradeDivisionMatrixId=@FromClassId AND sgdm.AcademicYearId = @AcademicYearId
	

    DECLARE @CurrentDateTime DATETIME = GETDATE();

    INSERT INTO dbo.StudentKitFeeParticular(AcademicYearId, GradeId, DivisionId, ParticularName, Amount, IsPublished, SortBy, CreatedBy, CreatedDate)
     SELECT @AcademicYearId, sgdm.GradeId, sgdm.DivisionId, f.ParticularName, f.Amount, 0, f.SortBy, @UserId, @CurrentDateTime 
     FROM dbo.StudentKitFeeParticular f CROSS JOIN 
     dbo.SchoolGradeDivisionMatrix sgdm  JOIN
     @ToClassId d ON sgdm.SchoolGradeDivisionMatrixId=d.Id
     WHERE f.GradeId=@FromGradeId AND f.DivisionId=@FromDivisionId AND
           f.AcademicYearId=@AcademicYearId AND f.IsDeleted <> 1;

	

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





