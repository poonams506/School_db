--===============================================
-- Author:    Meena Kotkar
-- Create date: 1/3/2024
-- Description:  This stored procedure is used Import Teacher Data
-- =============================================
CREATE PROCEDURE [dbo].[uspImportTeacherData](
  @TeacherImportType TeacherImportType READONLY,
  @UserId INT,
  @schoolCode NVARCHAR(20)
) AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE(); 
     DECLARE @MergeOutput TABLE (
        ActionTaken NVARCHAR(10) -- To store the action performed (INSERT or UPDATE)
    );
	DECLARE @InsertedCount INT;
	DECLARE @UpdatedCount INT;
  BEGIN TRY 

  MERGE Teacher AS Target
	USING (SELECT ST.FirstName,ST.MiddleName,
       ST.LastName,ST.Gender,ST.MobileNumber,
       ST.ContactNumber,ST.EmailId,ST.AddressLine1,
       ST.AddressLine2,
       ST.TalukaName,ST.DistrictName,ST.StateName,ST.CountryName,
       ST.Pincode,
       ST.AdharNumber,ST.Education,ST.BirthDate,
       ST.IsAppAccess,ST.AppAccessMobileNo,ST.BloodGroup ,
	   --(SELECT TOP 1 CountryId FROM Country WHERE CountryName = ST.CountryName) AS CountryId,
	   --(SELECT TOP 1 StateId FROM State WHERE StateName = ST.StateName) AS StateId,
	   --(SELECT TOP 1 DistrictId FROM District WHERE DistrictName = ST.DistrictName) AS DistrictId,
	   --(SELECT TOP 1 TalukaId FROM Taluka WHERE TalukaName = st.TalukaName)  AS TalukaId
	   ST.CountryId AS CountryId,
	   ST.StateId AS StateId,
	   ST.DistrictId AS DistrictId,
	   ST.TalukaId AS TalukaId
	   FROM  @TeacherImportType ST
		) As Source ON  CONCAT(Target.FirstName,Target.MiddleName,Target.LastName) = CONCAT(Source.FirstName,Source.MiddleName,Source.LastName)
		AND CONVERT(DATETIME,Target.BirthDate, 105)=CONVERT(DATETIME,Source.BirthDate, 105)AND ISNULL(Target.[IsDeleted],0)=0
		WHEN NOT MATCHED BY Target THEN 
		 INSERT(
       FirstName, MiddleName, 
       LastName, Gender,  MobileNumber, 
	   ContactNumber,EmailId, AddressLine1, 
       AddressLine2, 
	   TalukaId,DistrictId, StateId, CountryId,
       TalukaName, DistrictName, StateName, CountryName,
       ZipCode, 
       AdharNumber, Education, BirthDate, 
       IsAppAccess, AppAccessMobileNo, BloodGroup, 
       CreatedBy,CreatedDate
       ) 
       Values(Source.FirstName,Source.MiddleName,
       Source.LastName,Source.Gender,Source.MobileNumber,
       Source.ContactNumber,Source.EmailId,Source.AddressLine1,
       Source.AddressLine2,
	   Source.TalukaId, Source.DistrictId, Source.StateId, Source.CountryId,
       Source.TalukaName,Source.DistrictName,Source.StateName,Source.CountryName,
       Source.Pincode,
       Source.AdharNumber,Source.Education, CONVERT(DATE,Source.BirthDate, 105),
       Source.IsAppAccess,Source.AppAccessMobileNo,Source.BloodGroup,
	   @UserId,@CurrentDateTime
      ) 
	 WHEN MATCHED THEN UPDATE SET
         Target.FirstName = Source.FirstName, 
         Target.MiddleName = Source.MiddleName, 
         Target.LastName = Source.LastName, 
         Target.Gender = Source.Gender, 
         Target.ContactNumber = Source.ContactNumber, 
         Target.MobileNumber = Source.MobileNumber, 
         Target.EmailId = Source.EmailId, 
         Target.AddressLine1 = Source.AddressLine1, 
         Target.AddressLine2 = Source.AddressLine2, 
         Target.TalukaId = Source.TalukaId, 
         Target.DistrictId = Source.DistrictId, 
         Target.StateId = Source.StateId, 
         Target.CountryId = Source.CountryId, 
         Target.TalukaName = Source.TalukaName,
         Target.DistrictName = Source.DistrictName,
         Target.StateName = Source.StateName,
         Target.CountryName = Source.CountryName,
         Target.ZipCode = Source.Pincode, 
         Target.AdharNumber = Source.AdharNumber, 
         Target.Education = Source.Education, 
         Target.BirthDate =  CONVERT(DATETIME,Source.BirthDate, 105),
         Target.IsAppAccess =Source. IsAppAccess, 
         Target.AppAccessMobileNo = Source.AppAccessMobileNo, 
         Target.BloodGroup = Source.BloodGroup,  
         Target.ModifiedBy = @UserId, 
         Target.ModifiedDate = @CurrentDateTime

		    OUTPUT $action INTO @MergeOutput;

        -- Get the counts
        SELECT @InsertedCount = COUNT(*) FROM @MergeOutput WHERE ActionTaken = 'INSERT';
        SELECT @UpdatedCount = COUNT(*) FROM @MergeOutput WHERE ActionTaken = 'UPDATE';


		  -- Insert app users
        -- Declare cursor
        
        DECLARE @FirstName NVARCHAR(100), @MiddleName NVARCHAR(100),@LastName NVARCHAR(100),@BirthDate DateTime,
        @IsAppAccess BIT, @AppAccessOneTimePassword NVARCHAR(1000), @PasswordSalt NVARCHAR(1000), @Upassword NVARCHAR(1000), 
        @AppAccessMobileNo NVARCHAR(100)
        DECLARE teacher_cursor CURSOR FOR
        SELECT FirstName,MiddleName,LastName,BirthDate,
        IsAppAccess,AppAccessOneTimePassword,PasswordSalt,Upassword, AppAccessMobileNo
        FROM @TeacherImportType

        -- Open the cursor
        OPEN teacher_cursor

        -- Fetch the first row into variables
        FETCH NEXT FROM teacher_cursor INTO @FirstName, @MiddleName, @LastName, @BirthDate,
        @IsAppAccess, @AppAccessOneTimePassword, @PasswordSalt, @Upassword, @AppAccessMobileNo

        -- Loop through the cursor
        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @AppAccessOldMobileNo VARCHAR(20),@AppAccessOldUserId INT, @IsDifferentUserRoleExist BIT, @RefId INT;

            IF @IsAppAccess = 1
            BEGIN
                SET @AppAccessOldMobileNo=(SELECT TOP 1 AppAccessMobileNo FROM Teacher WHERE FirstName = @FirstName AND MiddleName = @MiddleName AND
                                            LastName = @LastName AND CONVERT (VARCHAR(100),BirthDate, 105) =CONVERT (VARCHAR(100),@BirthDate, 105) AND IsDeleted <> 1);
                 
                 SET @AppAccessOldUserId=(SELECT TOP 1 UserId FROM [User] WHERE MobileNumber=@AppAccessOldMobileNo AND Uname=@AppAccessOldMobileNo);
                  IF  EXISTS(SELECT 1 FROM Teacher WHERE AppAccessMobileNo=@AppAccessOldMobileNo)
                  BEGIN
                    SET @IsDifferentUserRoleExist=1;
                  END
                UPDATE Teacher SET AppAccessOneTimePassword = @AppAccessOneTimePassword WHERE FirstName = @FirstName AND MiddleName = @MiddleName AND
                                            LastName = @LastName AND CONVERT (VARCHAR(100),BirthDate, 105) =CONVERT (VARCHAR(100),@BirthDate, 105) AND IsDeleted <> 1; 
                SELECT @RefId = TeacherId FROM Teacher WHERE FirstName = @FirstName AND MiddleName = @MiddleName AND
                                            LastName = @LastName AND CONVERT (VARCHAR(100),BirthDate, 105) =CONVERT (VARCHAR(100),@BirthDate, 105) AND IsDeleted <> 1; 
                EXEC uspUserUpsert @IsAppAccess,@AppAccessOldUserId,@IsDifferentUserRoleExist,@AppAccessMobileNo,@Upassword,@PasswordSalt,3,@UserId,@FirstName,@LastName, @RefId
            
            END
        
            -- Fetch next row into variables
        FETCH NEXT FROM teacher_cursor INTO @FirstName, @MiddleName, @LastName, @BirthDate,
        @IsAppAccess, @AppAccessOneTimePassword, @PasswordSalt, @Upassword,@AppAccessMobileNo
        END

        -- Close the cursor
        CLOSE teacher_cursor
        -- Deallocate the cursor
        DEALLOCATE teacher_cursor
        -- end



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
	SELECT @InsertedCount AS 'InsertedCount', @UpdatedCount AS 'UpdatedCount';
  END