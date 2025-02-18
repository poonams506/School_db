CREATE PROCEDURE [dbo].[uspSchoolSettingSelect]
    @SchoolId SMALLINT = NULL,
    @AcademicYearId INT
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY 
        SELECT 
            Distinct S.SchoolId,
            S.AccountNumber,
            S.AccountTypeId,
            S.IFSCCode,
            S.AccountName,
            S.SchoolEmail,
            S.SchoolContactNo1,
            St.AcademicYearStartMonth,
            S.InvoiceNoPrefix,
            S.InvoiceNoStartNumber,
            S.SerialNoStartNumber,
            S.LangaugeCode,
            COALESCE(ST.IsSharedTransport, 0) AS IsSharedTransport,
            COALESCE(ST.IsFeeApplicableToStaff, 0) AS IsFeeApplicableToStaff,
            S.TransportInvoiceNoPrefix,
            S.TransportInvoiceNoStartNumber,
            S.AdditionalFeeInvoiceNoPrefix,
            S.AdditionalFeeInvoiceNoStartNumber,
            S.SchoolKitInvoiceNoPrefix,
            S.SchoolKitInvoiceNoStartNumber,
            S.RegistrationFeeInvoiceNoPrefix,
            S.RegistrationFeeInvoiceNoStartNumber
        FROM 
            School S
        LEFT JOIN 
            SchoolSetting ST ON ST.AcademicYearId = @AcademicYearId
        WHERE 
			S.IsDeleted <> 1;

        -- Additional query for SchoolTransportSetting
        SELECT 
            MonthId,
            SchoolId,
            AcademicYearId
        FROM 
            SchoolTransportSetting 
        WHERE 
             IsDeleted <> 1
            AND AcademicYearId = @AcademicYearId;

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
    END CATCH;
END;