-- =============================================
-- Author:        Saurabh Walunj
-- Create date:   04/07/2024
-- Description:   This stored procedure is used to get Gallery info detail by Select
-- =============================================
CREATE PROC uspGallerySelect 
(
    @GalleryId BIGINT
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @AcademicYearId INT;

        SELECT @AcademicYearId = g.AcademicYearId
        FROM dbo.Gallery AS g
        WHERE g.GalleryId = @GalleryId 
		AND g.IsDeleted <> 1;

        SELECT 
            g.GalleryId,
            g.AcademicYearId,
            g.GalleryToType,
            g.StartDate,
            g.Title AS GalleryTitle,
            g.Description,
            g.IsPublished
        FROM dbo.Gallery AS g
        WHERE g.GalleryId = @GalleryId 
		AND g.IsDeleted <> 1;

        SELECT 
            g.GalleryId,
            gd.FileName,
            gd.FileType
        FROM dbo.GalleryDetails AS gd
		INNER JOIN Gallery AS g ON gd.GalleryId = g.GalleryId
        WHERE g.GalleryId = @GalleryId
		AND gd.IsDeleted <> 1 
		AND gd.FileType = 1;

        SELECT 
            g.GalleryId,
            gmd.ContentUrl
        FROM dbo.GalleryMediaDetails AS gmd
		INNER JOIN Gallery AS g ON gmd.GalleryId = g.GalleryId
        WHERE g.GalleryId = @GalleryId
		AND gmd.IsDeleted <> 1 

        SELECT 
            gm.GalleryId,
            gm.StudentId,
            sgdm.SchoolGradeDivisionMatrixId AS ClassId,
            gm.TeacherId,
            gm.ClerkId,
            gm.CabDriverId
        FROM dbo.GalleryMapping gm
        LEFT JOIN dbo.SchoolGradeDivisionMatrix sgdm 
            ON gm.GradeId = sgdm.GradeId 
            AND gm.DivisionId = sgdm.DivisionId 
            AND sgdm.AcademicYearId = @AcademicYearId
        WHERE gm.GalleryId = @GalleryId
        AND (sgdm.IsDeleted <> 1 OR sgdm.SchoolGradeDivisionMatrixId IS NULL);

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
    END CATCH
END

