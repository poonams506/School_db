-- =============================================
-- Author: Saurabh Walunj 
-- Create date: 25/07/2024
-- Description: This stored procedure is used for Exam Report Card Upsert 
-- =============================================
CREATE PROCEDURE [dbo].[uspExamReportCardUpsert](
   @ExamReportCardNameId BIGINT,
   @AcademicYearId SMALLINT,
   @ReportCardName NVARCHAR(200),
   @Description NVARCHAR(2000),
   @ExamMasterIds [SingleIdType] READONLY,
   @ClassIds [SingleIdType] READONLY,
   @IsTwoDifferentExamSection BIT,
   @UserId INT

) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
  DECLARE @CurrentDateTime DATETIME = GETDATE();

BEGIN TRY
IF EXISTS (
			--SELECT TOP (1) ExamReportCardNameId  FROM dbo.CBSE_ExamReportCardName
--			WHERE ExamReportCardNameId<>@ExamReportCardNameId AND 
--			ReportCardName=@ReportCardName AND
--			IsDeleted<>1 ORDER BY ReportCardName)

	SELECT TOP (1) 1
    FROM dbo.CBSE_ExamReportCardName rcn
    INNER JOIN dbo.CBSE_ReportCardExam rce ON rcn.ExamReportCardNameId = rce.ExamReportCardNameId
    INNER JOIN dbo.CBSE_ReportCardClasses rcc ON rcn.ExamReportCardNameId = rcc.ExamReportCardNameId
    WHERE rcn.ExamReportCardNameId <> @ExamReportCardNameId
      AND rcn.ReportCardName = @ReportCardName
      AND rcn.IsDeleted <> 1
      AND rce.ExamMasterId IN (SELECT Id FROM @ExamMasterIds)
      AND rcc.GradeId IN (
          SELECT sgdm.GradeId
          FROM @ClassIds c
          JOIN dbo.SchoolGradeDivisionMatrix sgdm 
          ON c.Id = sgdm.SchoolGradeDivisionMatrixId
      ))
	BEGIN
		SELECT -1;
	END
	ELSE
	BEGIN
IF @ExamReportCardNameId > 0 BEGIN --Update Statement
 
--Update Statement
UPDATE 
  CBSE_ExamReportCardName
SET 
  [AcademicYearId] = @AcademicYearId,
  [ReportCardName] = @ReportCardName, 
  [Description] = @Description,
  [IsTwoDifferentExamSection] = @IsTwoDifferentExamSection,
  [ModifiedBy] = @UserId, 
  [ModifiedDate] = @CurrentDateTime
   WHERE 
      [ExamReportCardNameId] =  @ExamReportCardNameId  --INSERT Statement
   -- update for CBSE_ReportCardClasses
             DELETE FROM dbo.CBSE_ReportCardClasses
    WHERE ExamReportCardNameId = @ExamReportCardNameId;
	
             DELETE FROM dbo.CBSE_ReportCardExam
    WHERE ExamReportCardNameId = @ExamReportCardNameId;

             -- insert for CBSE_ReportCardClasses
            INSERT INTO dbo.CBSE_ReportCardClasses(ExamReportCardNameId, GradeId, DivisionId, AcademicYearId,CreatedBy, CreatedDate)
            Select @ExamReportCardNameId, sgdm.GradeId, sgdm.DivisionId, @AcademicYearId,@UserId, @CurrentDateTime FROM @ClassIds c JOIN
            dbo.SchoolGradeDivisionMatrix sgdm ON  c.Id=sgdm.SchoolGradeDivisionMatrixId and sgdm.AcademicYearId = @AcademicYearId;

	 

            --INSERT INTO dbo.CBSE_ReportCardExam(ExamMasterId, ExamReportCardNameId, ReportCardExamId)
            --Values (@ExamMasterId, @ExamReportCardNameId, @ReportCardName)
			
			 INSERT INTO dbo.CBSE_ReportCardExam(ExamMasterId, ExamReportCardNameId,TermId,AcademicYearId,CreatedBy, CreatedDate)
             Select ExamMasterId, @ExamReportCardNameId, csm.TermId,@AcademicYearId, @UserId, @CurrentDateTime FROM @ExamMasterIds em JOIN
            dbo.CBSE_ExamMaster csm ON  em.Id=csm.ExamMasterId and csm.AcademicYearId = @AcademicYearId;
			
             
  END 
  ELSE 
  BEGIN --INSERT Statement
  INSERT INTO CBSE_ExamReportCardName(
         [AcademicYearId],
		 [ReportCardName], 
         [Description], 
		 [IsTwoDifferentExamSection],
         [CreatedBy],
         [CreatedDate]
       ) 
    VALUES 
 (
  @AcademicYearId,
  @ReportCardName,
  @Description,
  @IsTwoDifferentExamSection,
  @UserId,
  @CurrentDateTime
 )
  SET @ExamReportCardNameId = SCOPE_IDENTITY();

             -- insert for CBSE_ReportCardClasses
            INSERT INTO dbo.CBSE_ReportCardClasses(ExamReportCardNameId, GradeId, DivisionId,AcademicYearId, CreatedBy, CreatedDate)
            Select @ExamReportCardNameId, sgdm.GradeId, sgdm.DivisionId,@AcademicYearId, @UserId, @CurrentDateTime FROM @ClassIds c JOIN
            dbo.SchoolGradeDivisionMatrix sgdm ON  c.Id=sgdm.SchoolGradeDivisionMatrixId and sgdm.AcademicYearId = @AcademicYearId;


            --INSERT INTO dbo.CBSE_ReportCardExam(ExamMasterId, ExamReportCardNameId, ReportCardExamId)
            --Values (@ExamMasterId, @ExamReportCardNameId, @ExamReportCardNameId)

			 INSERT INTO dbo.CBSE_ReportCardExam(ExamMasterId, ExamReportCardNameId,TermId,AcademicYearId,CreatedBy, CreatedDate)
             Select ExamMasterId, @ExamReportCardNameId, csm.TermId,@AcademicYearId, @UserId, @CurrentDateTime FROM @ExamMasterIds em JOIN
            dbo.CBSE_ExamMaster csm ON  em.Id=csm.ExamMasterId and csm.AcademicYearId = @AcademicYearId;

		
     

 END 
 END
 END TRY 
 BEGIN CATCH
 DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
 DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
 DECLARE @ErrorState INT = ERROR_STATE();
 DECLARE @ErrorNumber INT = ERROR_NUMBER();
 DECLARE @ErrorLine INT = ERROR_PROCEDURE();
 DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_LINE();
 EXEC uspExceptionLogInsert @ErrorLine, 
 @ErrorMessage, 
 @ErrorNumber, 
 @ErrorProcedure, 
 @ErrorSeverity, 
 @ErrorState;
 END CATCH END
   
