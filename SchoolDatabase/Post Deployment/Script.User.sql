/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

DECLARE @User TABLE([UserId] INT,[TitleId] INT,[Fname] NVARCHAR(50),[Mname] NVARCHAR(50),[Lname] NVARCHAR(50),
                    [EmailAddress] NVARCHAR(150),[MobileNumber] NVARCHAR(20), 
                    [Uname] NVARCHAR (250) NOT NULL,[Upassword]     NVARCHAR (MAX) NOT NULL,
                    [PasswordSalt] NVARCHAR (250) NOT NULL);

INSERT INTO @User([UserId],[TitleId],[Fname],[Mname],[Lname],[EmailAddress],[MobileNumber],
                  [Uname],[Upassword],[PasswordSalt]) VALUES(1,1,'Super','','Admin','kusumghule.dna@gmail.com','',
                  'admin','$2a$12$jGW7G9uPLlzH3nMb.NKueOcJm/bovj9LWSrBmxeeXDCVm3EOlp0r.','$2a$12$jGW7G9uPLlzH3nMb.NKueO');

MERGE INTO dbo.[User] AS Target
USING @User AS Source 
ON Source.UserId=Target.UserId
--WHEN MATCHED THEN
--UPDATE SET Target.TitleId=Source.TitleId,Target.Fname=Source.Fname,
--           Target.Lname=Source.Lname,Target.EmailAddress=Source.EmailAddress,
--           Target.MobileNumber=Source.MobileNumber,Target.Uname=Source.Uname,
--           Target.Upassword=Source.Upassword,Target.PasswordSalt=Source.PasswordSalt
WHEN NOT MATCHED THEN
INSERT([TitleId],[Fname],[Mname],[Lname],[EmailAddress],[MobileNumber],
                  [Uname],[Upassword],[PasswordSalt]) 
VALUES(Source.TitleId,Source.Fname,Source.Mname,Source.Lname,Source.EmailAddress,
           Source.MobileNumber,Source.Uname,Source.Upassword,Source.PasswordSalt);
