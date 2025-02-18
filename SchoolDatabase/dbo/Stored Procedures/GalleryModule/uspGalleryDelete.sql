-- =============================================
-- Author:    Saurabh Walunj
-- Create date: 5/7/2024
-- Description:  This stored procedure is used delete Gallery Data
-- =============================================
CREATE PROCEDURE [dbo].[uspGalleryDelete](
  @GalleryId INT = NULL,
  @UserId INT=NULL
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
  BEGIN TRY
    -- Soft delete Gallery
    UPDATE dbo.Gallery 
    SET IsDeleted = 1,
    ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
    WHERE GalleryId = @GalleryId;

    -- Soft delete associated GalleryDetails
    UPDATE dbo.GalleryDetails 
    SET IsDeleted = 1,
    ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
    WHERE GalleryId = @GalleryId;
              
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


