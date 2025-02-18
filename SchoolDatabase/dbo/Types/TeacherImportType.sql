CREATE TYPE [dbo].[TeacherImportType] AS TABLE
(
 
  FirstName NVARCHAR(50), 
  MiddleName NVARCHAR(50), 
  LastName NVARCHAR(50), 
  Gender NVARCHAR(5), 
  MobileNumber NVARCHAR(20), 
  ContactNumber NVARCHAR(20), 
  EmailId VARCHAR(80), 
  AddressLine1 NVARCHAR(250), 
  AddressLine2 NVARCHAR(250), 
  CountryName NVARCHAR(100), 
  StateName NVARCHAR(100), 
  DistrictName NVARCHAR(100), 
  TalukaName NVARCHAR(100), 
  Pincode NVARCHAR(10), 
  AdharNumber NVARCHAR(20), 
  Education NVARCHAR(50), 
  BirthDate DATETIME , 
  BloodGroup NVARCHAR(5),
  IsAppAccess BIT DEFAULT(0) NOT NULL, 
  AppAccessMobileNo NVARCHAR(20),
   AppAccessOneTimePassword VARCHAR(1000),
  PasswordSalt VARCHAR(1000),
  Upassword VARCHAR(1000),
  CountryId INT,
  StateId INT,
  DistrictId INT,
  TalukaId INT
   
)
