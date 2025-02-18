-- =============================================
-- Author: Poonam Bhalke
-- Create date: 28/08/2023
-- Description: This stored procedure is used for doing Homework Upsert
-- =============================================
CREATE PROCEDURE [dbo].[uspHomeWorkUpsert]
	@HomeWorkId BIGINT,
    @AcademicYearId SMALLINT,
    --@GradeId SMALLINT,
    --@DivisionId SMALLINT,
	@ClassId INT,
    @SubjectId BIGINT,
    @HomeworkTitle NVARCHAR(100),
    @HomeworkDescription NVARCHAR(1000),
    @StartDate DATETIME,
    @EndDate DATETIME,
    @IsPublished BIT,
    @UserId INT,
    @HomeWorkFileDetails [HomeWorkFileDetailType] READONLY,
    @Mediadetails [MediaType] READONLY  -- Added parameter for media details

AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    DECLARE @CurrentDateTime DATETIME = GETDATE();
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

    BEGIN TRY 
        IF @HomeWorkId > 0  
        BEGIN -- Update Statement
            -- update for homework
            UPDATE dbo.HomeWork
            SET 
                [GradeId] = @GradeId,
                [DivisionId] = @DivisionId,
                [SubjectId] = @SubjectId,
                [Title] = @HomeworkTitle,
                [Description] = @HomeworkDescription,
                [StartDate] = @StartDate,
                [EndDate] = @EndDate,
                [IsPublished] = @IsPublished,
                [ModifiedBy] = @UserId, 
                [ModifiedDate] = @CurrentDateTime 
            WHERE 
                [HomeWorkId] = @HomeWorkId;

            -- update for homeworkdetails
            DELETE FROM dbo.HomeWorkDetails 
            WHERE HomeWorkId = @HomeWorkId;

            INSERT INTO dbo.HomeWorkDetails(HomeWorkId, FileName, FileType, CreatedBy, CreatedDate)
            SELECT @HomeWorkId, hwt.FileName, hwt.FileType, @UserId, @CurrentDateTime
            FROM @HomeWorkFileDetails AS hwt;

            
            -- Delete existing media details for the homework
            DELETE FROM dbo.HomeworkMediaDetail
            WHERE 
                HomeWorkId = @HomeWorkId;

            -- Insert new media details
            INSERT INTO dbo.HomeworkMediaDetail(HomeWorkId, ContentUrl, CreatedBy, CreatedDate)
            SELECT 
                @HomeWorkId, 
                md.ContentUrl, 
                @UserId, 
                @CurrentDateTime
            FROM
                @Mediadetails AS md;
        END
        ELSE
        BEGIN --INSERT Statement
            --insert for homework
            INSERT INTO dbo.HomeWork 
            (
                [AcademicYearId],[GradeId],[DivisionId],[SubjectId],
                [Title], [Description], [StartDate], [EndDate], [IsPublished],
                [CreatedBy], [CreatedDate]
            )
            VALUES 
            (
                @AcademicYearId, @GradeId, @DivisionId, @SubjectId,
                @HomeworkTitle, @HomeworkDescription, @StartDate, @EndDate, @IsPublished,
                @UserId, @CurrentDateTime
            );

            SET @HomeWorkId = SCOPE_IDENTITY();

            -- insert for homeworkdetail
            INSERT INTO dbo.HomeWorkDetails(HomeWorkId, FileName, FileType, CreatedBy, CreatedDate)
            SELECT @HomeWorkId, hwt.FileName, hwt.FileType, @UserId, @CurrentDateTime
            FROM @HomeWorkFileDetails AS hwt;

             -- Insert for homework media details
            INSERT INTO dbo.HomeworkMediaDetail(HomeWorkId, ContentUrl, CreatedBy, CreatedDate)
            SELECT 
                @HomeWorkId, 
                md.ContentUrl, 
                @UserId, 
                @CurrentDateTime
            FROM
                @Mediadetails AS md;
        END   
    END TRY
    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
        
        EXEC uspExceptionLogInsert 
            @ErrorLine, 
            @ErrorMessage, 
            @ErrorNumber, 
            @ErrorProcedure, 
            @ErrorSeverity, 
            @ErrorState;
    END CATCH;
END;
