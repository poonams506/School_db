-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 30/08/2023
-- Description:  This stored procedure is used update school profile setting
-- =============================================
CREATE PROCEDURE [dbo].[uspSchoolSettingUpsert] (
  @SchoolId SMALLINT, 
  @AcademicYearId SMALLINT, 
  @AccountNumber NVARCHAR(50),
  @AccountTypeId INT,
  @IFSCCode NVARCHAR(50),
  @AccountName NVARCHAR(150),
  @AcademicYearStartMonth DATETIME, 
  @InvoiceNoPrefix NVARCHAR(20),
  @InvoiceNoStartNumber INT,
  @TransportInvoiceNoPrefix NVARCHAR(20),
  @TransportInvoiceNoStartNumber INT,
  @AdditionalFeeInvoiceNoPrefix NVARCHAR(20) ,
  @AdditionalFeeInvoiceNoStartNumber INT,
  @SchoolKitInvoiceNoPrefix NVARCHAR(20),
  @SchoolKitInvoiceNoStartNumber INT,
  @RegistrationFeeInvoiceNoPrefix  NVARCHAR(20),
  @RegistrationFeeInvoiceNoStartNumber INT,
  @SerialNoStartNumber INT,
  @LangaugeCode NVARCHAR(150),
  @IsSharedTransport BIT,
  @IsFeeApplicableToStaff BIT,
  @UserId INT,
  @MonthList SingleIdType READONLY
) AS 
BEGIN 
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
  SET NOCOUNT ON;
  DECLARE @CurrentDateTime DATETIME = GETDATE();
  
  BEGIN TRY 
    DECLARE @OldInvoiceNoStartNumber INT;
    DECLARE @OldAdditionalFeeInvoiceNoStartNumber INT;
    DECLARE @OldTransportInvoiceNoStartNumber INT;
    DECLARE @OldSchoolKitInvoiceNoStartNumber INT;
     DECLARE @OldRegistrationFeeInvoiceNoStartNumber INT;
    SELECT @OldInvoiceNoStartNumber = InvoiceNoStartNumber FROM dbo.School WHERE [SchoolId] = @SchoolId;
    SELECT @OldAdditionalFeeInvoiceNoStartNumber = AdditionalFeeInvoiceNoStartNumber FROM dbo.School WHERE [SchoolId] = @SchoolId;
    SELECT @OldTransportInvoiceNoStartNumber = TransportInvoiceNoStartNumber FROM dbo.School WHERE [SchoolId] = @SchoolId;
    SELECT @OldSchoolKitInvoiceNoStartNumber = SchoolKitInvoiceNoStartNumber FROM dbo.School WHERE [SchoolId] = @SchoolId;
    SELECT @OldRegistrationFeeInvoiceNoStartNumber = RegistrationFeeInvoiceNoStartNumber FROM dbo.School WHERE [SchoolId] = @SchoolId;

    -- Update School table
    UPDATE dbo.School 
    SET 
      AccountNumber = @AccountNumber,
      AccountTypeId = @AccountTypeId,
      IFSCCode = @IFSCCode,
      AccountName = @AccountName,
      InvoiceNoPrefix = @InvoiceNoPrefix,
      InvoiceNoStartNumber = @InvoiceNoStartNumber,
      TransportInvoiceNoPrefix = @TransportInvoiceNoPrefix,
      TransportInvoiceNoStartNumber = @TransportInvoiceNoStartNumber,
      AdditionalFeeInvoiceNoPrefix = @AdditionalFeeInvoiceNoPrefix,
      AdditionalFeeInvoiceNoStartNumber = @AdditionalFeeInvoiceNoStartNumber,
      SchoolkitInvoiceNoPrefix = @SchoolkitInvoiceNoPrefix,
      SchoolkitInvoiceNoStartNumber = @SchoolkitInvoiceNoStartNumber,
      RegistrationFeeInvoiceNoPrefix=@RegistrationFeeInvoiceNoPrefix,
      RegistrationFeeInvoiceNoStartNumber=@RegistrationFeeInvoiceNoStartNumber,
      SerialNoStartNumber = @SerialNoStartNumber,
      LangaugeCode = @LangaugeCode,
      ModifiedBy = @UserId, 
      ModifiedDate = @CurrentDateTime
    WHERE 
      SchoolId = @SchoolId;

    -- Insert or update SchoolSetting
    IF EXISTS (SELECT 1 FROM dbo.SchoolSetting WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1)
    BEGIN
      UPDATE dbo.SchoolSetting
      SET 
        AcademicYearStartMonth = @AcademicYearStartMonth,
        IsSharedTransport = @IsSharedTransport,
        IsFeeApplicableToStaff = @IsFeeApplicableToStaff,
        AcademicYearId = @AcademicYearId,
        ModifiedBy = @UserId,
        ModifiedDate = @CurrentDateTime
      WHERE 
        AcademicYearId = @AcademicYearId
    END
    ELSE
    BEGIN
      INSERT INTO dbo.SchoolSetting(SchoolId, AcademicYearStartMonth, IsSharedTransport, IsFeeApplicableToStaff, AcademicYearId, CreatedBy, CreatedDate) 
      VALUES (@SchoolId, @AcademicYearStartMonth, @IsSharedTransport, @IsFeeApplicableToStaff, @AcademicYearId, @UserId, @CurrentDateTime);
    END;

    -- Insert new records into SchoolTransportSetting
	  
	 DELETE FROM dbo.SchoolTransportSetting WHERE AcademicYearId = @AcademicYearId

    INSERT INTO dbo.SchoolTransportSetting(SchoolId, MonthId, AcademicYearId, CreatedBy, CreatedDate) 
    SELECT @SchoolId, mt.Id, @AcademicYearId, @UserId, @CurrentDateTime 
    FROM @MonthList mt;


    -- Recreate sequence if InvoiceNoStartNumber has changed
    IF @OldInvoiceNoStartNumber <> @InvoiceNoStartNumber OR @OldInvoiceNoStartNumber is null
    BEGIN
      DROP SEQUENCE IF EXISTS dbo.InvoiceSequence;
      DECLARE @sql NVARCHAR(MAX);
      SET @sql = 'CREATE SEQUENCE dbo.InvoiceSequence 
                  AS [bigint]
                  START WITH ' + CAST(@InvoiceNoStartNumber AS NVARCHAR(50)) + '
                  INCREMENT BY 1
                  MINVALUE 1
                  MAXVALUE 99999999999;';
      EXEC(@sql);
    END;
    IF @OldAdditionalFeeInvoiceNoStartNumber <> @AdditionalFeeInvoiceNoStartNumber OR @OldAdditionalFeeInvoiceNoStartNumber is null
    BEGIN
      DROP SEQUENCE IF EXISTS dbo.AdditionalInvoiceSequence;
      DECLARE @sqlAdd NVARCHAR(MAX);
      SET @sqlAdd = 'CREATE SEQUENCE dbo.AdditionalInvoiceSequence 
                  AS [bigint]
                  START WITH ' + CAST(@AdditionalFeeInvoiceNoStartNumber AS NVARCHAR(50)) + '
                  INCREMENT BY 1
                  MINVALUE 1
                  MAXVALUE 99999999999;';
      EXEC(@sqlAdd);
    END;
    IF @OldTransportInvoiceNoStartNumber <> @TransportInvoiceNoStartNumber OR @OldTransportInvoiceNoStartNumber is null
    BEGIN
      DROP SEQUENCE IF EXISTS dbo.TransportInvoiceSequence;
      DECLARE @sqlTransport NVARCHAR(MAX);
      SET @sqlTransport = 'CREATE SEQUENCE dbo.TransportInvoiceSequence 
                  AS [bigint]
                  START WITH ' + CAST(@TransportInvoiceNoStartNumber AS NVARCHAR(50)) + '
                  INCREMENT BY 1
                  MINVALUE 1
                  MAXVALUE 99999999999;';
      EXEC(@sqlTransport);
    END;
     IF @OldSchoolKitInvoiceNoStartNumber <> @SchoolKitInvoiceNoStartNumber OR @OldSchoolKitInvoiceNoStartNumber is null
    BEGIN
      DROP SEQUENCE IF EXISTS dbo.SchoolKitInvoiceSequence;
      DECLARE @sqlSchoolKit NVARCHAR(MAX);
      SET @sqlSchoolKit = 'CREATE SEQUENCE dbo.SchoolKitInvoiceSequence 
                  AS [bigint]
                  START WITH ' + CAST(@SchoolKitInvoiceNoStartNumber AS NVARCHAR(50)) + '
                  INCREMENT BY 1
                  MINVALUE 1
                  MAXVALUE 99999999999;';
      EXEC(@sqlSchoolKit);
    END;

    IF @OldRegistrationFeeInvoiceNoStartNumber <> @RegistrationFeeInvoiceNoStartNumber OR @OldRegistrationFeeInvoiceNoStartNumber is null
    BEGIN
      DROP SEQUENCE IF EXISTS dbo.RegistrationFeeInvoiceSequence;
      DECLARE @sqlRegistrationFee NVARCHAR(MAX);
      SET @sqlRegistrationFee = 'CREATE SEQUENCE dbo.RegistrationFeeInvoiceSequence 
                  AS [bigint]
                  START WITH ' + CAST(@RegistrationFeeInvoiceNoStartNumber AS NVARCHAR(50)) + '
                  INCREMENT BY 1
                  MINVALUE 1
                  MAXVALUE 99999999999;';
      EXEC(@sqlRegistrationFee);
    END;



  END TRY 
  BEGIN CATCH 
    DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
    EXEC uspExceptionLogInsert @ErrorLine, @ErrorMessage, @ErrorNumber, @ErrorProcedure, @ErrorSeverity, @ErrorState;
  END CATCH;

  SELECT @SchoolId;
END;
