-- =============================================
-- Author:    Shambala Apugade
-- Create date: 25/08/2023
-- Description:  This stored procedure is used insert FeeParticular data
-- =============================================
CREATE PROCEDURE uspStudentKitFeeParticularUpdate
(
	@AcademicYearId SMALLINT,
	@ClassId INT,
	@IsPublish BIT = 0,
	@UserId INT,
	@FeeParticulars dbo.StudentKitFeeParticularType READONLY
)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
    DECLARE @GradeId INT;
    DECLARE @DivisionId INT;
	SELECT 
      @GradeId=sgdm.GradeId,
      @DivisionId=sgdm.DivisionId

  FROM  
  dbo.SchoolGradeDivisionMatrix sgdm JOIN
  dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
  dbo.Division d ON sgdm.DivisionId=d.DivisionId
  WHERE sgdm.IsDeleted <> 1 AND sgdm.SchoolGradeDivisionMatrixId=@ClassId AND sgdm.AcademicYearId = @AcademicYearId
	
DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
-- to do 
     BEGIN TRANSACTION
     --hard delete FeeParticular
	 DELETE  fp FROM dbo.StudentKitFeeParticular fp
	 WHERE 
	 NOT  EXISTS (SELECT FeeParticularId 
	                     FROM @FeeParticulars WHERE FeeParticularId>0 AND
	                     FeeParticularId=fp.FeeParticularId)
	 AND GradeId = @GradeId
	 AND DivisionId = @DivisionId
         AND AcademicYearId = @AcademicYearId
	
     UPDATE dbo.StudentKitFeeParticular SET ParticularName = f.ParticularName, Amount = f.Amount,  IsPublished = @IsPublish, SortBy = f.SortBy,
	 ModifiedBy = @UserId, ModifiedDate = @CurrentDateTime
	 FROM @FeeParticulars f WHERE StudentKitFeeParticular.FeeParticularId = f.FeeParticularId
	 AND StudentKitFeeParticular.GradeId = @GradeId
	 AND StudentKitFeeParticular.DivisionId = @DivisionId

     INSERT INTO dbo.StudentKitFeeParticular(AcademicYearId ,GradeId, DivisionId, ParticularName, Amount, IsPublished, SortBy, CreatedBy, CreatedDate)
     SELECT @AcademicYearId, @GradeId, @DivisionId, f.ParticularName, f.Amount, @IsPublish, SortBy, @UserId, @CurrentDateTime FROM @FeeParticulars f
	 WHERE ISNULL(f.FeeParticularId,0) = 0 


	


	 COMMIT TRANSACTION
END TRY BEGIN CATCH 
ROLLBACK TRANSACTION
DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
@ErrorState END CATCH END
