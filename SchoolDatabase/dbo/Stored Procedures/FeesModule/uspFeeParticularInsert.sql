-- =============================================
-- Author:    Shambala Apugade
-- Create date: 25/08/2023
-- Description:  This stored procedure is used insert FeeParticular data
-- =============================================
CREATE PROCEDURE uspFeeParticularInsert
(
	@AcademicYearId SMALLINT,
	@IsPublish BIT = 0,
	@UserId INT,
	@ClassId [dbo].[SingleIdType] READONLY,
	@FeeParticulars dbo.FeeParticularType READONLY,
	@FeeParticularWavierMappingTypes dbo.FeeParticularWavierMappingType READONLY
)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
	 
	
      DECLARE @CurrentDateTime DATETIME = GETDATE();

     INSERT INTO dbo.FeeParticular(AcademicYearId, GradeId, DivisionId, ParticularName, Amount, IsDiscountApplicable,IsRTEApplicable, IsPublished, SortBy, CreatedBy, CreatedDate)
     SELECT @AcademicYearId, sgdm.GradeId, sgdm.DivisionId, f.ParticularName, f.Amount, f.IsDiscountApplicable,f.IsRTEApplicable, @IsPublish, f.SortBy, @UserId, @CurrentDateTime 
	 FROM @FeeParticulars f CROSS JOIN 
     dbo.SchoolGradeDivisionMatrix sgdm  JOIN
     @ClassId c ON sgdm.SchoolGradeDivisionMatrixId=c.Id;

	 INSERT INTO dbo.FeeParticularWavierMapping(AcademicYearId, GradeId, DivisionId, FeeWavierTypeId, CreatedBy, CreatedDate)
     SELECT @AcademicYearId, sgdm.GradeId, sgdm.DivisionId, f.FeeWavierTypeId, @UserId, @CurrentDateTime 
	 from  @FeeParticularWavierMappingTypes f CROSS JOIN
     dbo.SchoolGradeDivisionMatrix sgdm JOIN
     @ClassId c ON sgdm.SchoolGradeDivisionMatrixId=c.Id;
END

