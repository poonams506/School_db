-- Author:    Shambala Apugade
-- Create date: 18/06/2024
-- Description:  This stored procedure is used to get Route info 
-- =============================================
CREATE PROCEDURE [dbo].[uspCabDriverTripDetailUpsert]
(
@TripId BIGINT,
@StudentId BIGINT,
@UserId INT
) 
AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON 
DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 

DECLARE @TripType NVARCHAR(10)
SELECT @Triptype = TripType FROM dbo.Trip WHERE TripId= @tripId

IF @TripType = 'PickUp' 
BEGIN 

	MERGE INTO dbo.TripDetail AS target 
	USING (SELECT @TripId AS TripId,@StudentId AS StudentId,@UserId AS UserId)
	AS source ON target.TripId=source.TripId AND target.StudentId=source.StudentId
	WHEN NOT MATCHED THEN 
	INSERT(TripId,StudentId,PickUpDateTime,CreatedDate)
	VALUES(source.TripId,source.StudentId,@CurrentDateTime,@CurrentDateTime)
	WHEN MATCHED THEN
		UPDATE SET target.ModifiedDate=@CurrentDateTime;
END
ELSE
BEGIN
	MERGE INTO dbo.TripDetail AS target 
	USING (SELECT @TripId AS TripId,@StudentId AS StudentId,@UserId AS UserId)
	AS source ON target.TripId=source.TripId AND target.StudentId=source.StudentId
	WHEN NOT MATCHED THEN 
	INSERT(TripId,StudentId,PickUpDateTime,CreatedDate)
	VALUES(source.TripId,source.StudentId,@CurrentDateTime,@CurrentDateTime)
	WHEN MATCHED THEN
		UPDATE SET target.ModifiedDate=@CurrentDateTime;
END


SELECT SCOPE_IDENTITY(); 
END TRY 
BEGIN CATCH 
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

