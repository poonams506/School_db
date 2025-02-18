﻿-- =============================================
-- Author:    Deepak W
-- Create date: 28/12/2023
-- Description:  This stored procedure is used copy data from last AY
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentKitFeeParticularCopyFromLastAY]
(
   @GradeId INT,
   @DivisionId INT
)
 AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

    BEGIN TRY
		DECLARE @currentAcademicYearId INT, @lastAcademicYearId INT;
        SET @currentAcademicYearId = (SELECT TOP (1) AcademicYearId FROM dbo.School ORDER BY SchoolId DESC);
        SET @lastAcademicYearId = @currentAcademicYearId - 1;

        INSERT INTO dbo.StudentKitFeeParticular(
        AcademicYearId,
        GradeId,
        DivisionId,
        ParticularName,
        Amount,
        IsPublished,
        SortBy,
        CreatedBy,
        CreatedDate,
        ModifiedBy,
        ModifiedDate,
        IsDeleted
        )
        SELECT 
        @currentAcademicYearId,
        GradeId,
        DivisionId,
        ParticularName,
        Amount,
        0,
        SortBy,
        CreatedBy,
        CreatedDate,
        ModifiedBy,
        ModifiedDate,
        IsDeleted
        FROM
        dbo.StudentKitFeeParticular
        WHERE GradeId = @GradeId AND DivisionId = @DivisionId AND AcademicYearId = @lastAcademicYearId AND IsDeleted <> 1

		IF NOT EXISTS (SELECT TOP (1) FeeParticularId FROM
        dbo.StudentKitFeeParticular
        WHERE GradeId = @GradeId AND DivisionId = @DivisionId AND AcademicYearId = @lastAcademicYearId AND IsDeleted <> 1)
		BEGIN
		     SELECT -1 AS result
		END
		ELSE
		BEGIN
		     SELECT 1 AS result
		END
        
    END TRY
    BEGIN CATCH
      -- Log the exception
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
                                 @ErrorState;

     
    END CATCH
  END
  