-- =============================================
-- Author:    Shambala Apugade
-- Create date: 25/08/2023
-- Description:  This stored procedure is used insert FeeParticular data
-- =============================================
CREATE PROCEDURE uspStudentKitFeeParticularInsert
(
	@AcademicYearId SMALLINT,
	@IsPublish BIT = 0,
	@UserId INT,
	@ClassId [dbo].[SingleIdType] READONLY,
	@FeeParticulars dbo.StudentKitFeeParticularType READONLY
)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
	 
	
      DECLARE @CurrentDateTime DATETIME = GETDATE();

     INSERT INTO dbo.StudentKitFeeParticular(AcademicYearId, GradeId, DivisionId, ParticularName, Amount, IsPublished, SortBy, CreatedBy, CreatedDate)
     SELECT @AcademicYearId, sgdm.GradeId, sgdm.DivisionId, f.ParticularName, f.Amount, @IsPublish, f.SortBy, @UserId, @CurrentDateTime 
	 FROM @FeeParticulars f CROSS JOIN 
     dbo.SchoolGradeDivisionMatrix sgdm  JOIN
     @ClassId c ON sgdm.SchoolGradeDivisionMatrixId=c.Id;

	
END

