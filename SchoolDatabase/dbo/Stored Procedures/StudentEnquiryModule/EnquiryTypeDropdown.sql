﻿-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 20/08/2024
-- Description:  This stored procedure is used to get Enquiry Type dropdown
-- =============================================
CREATE PROC uspEnquiryTypeDropdown AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT 
  EnquiryTypeId,
  EnquiryTypeName
FROM 
  dbo.EnquiryType
WHERE 
  IsDeleted <> 1
  ORDER BY EnquiryTypeName;
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


















