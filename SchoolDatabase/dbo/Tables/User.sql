CREATE TABLE [dbo].[User] (
    [UserId]            INT            IDENTITY (1, 1) NOT NULL,
    [TitleId] INT,
    [Fname] NVARCHAR(50),
    [Mname] NVARCHAR(50),
    [Lname] NVARCHAR(50),
    [EmailAddress] NVARCHAR(150),
    [MobileNumber] NVARCHAR(20),
    [Uname]         NVARCHAR (250) NOT NULL,
    [Upassword]     NVARCHAR (MAX) NOT NULL,
    [PasswordSalt] NVARCHAR (250) NOT NULL,
    [IsFirstTimeLogin] BIT DEFAULT ((1)) NOT NULL,
    [FCMToken] NVARCHAR(250),
    [IsDeleted]    BIT            DEFAULT ((0)) NOT NULL,
    [CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
    CONSTRAINT [PKUser] PRIMARY KEY CLUSTERED ([UserId] ASC),
    CONSTRAINT UKUser UNIQUE (Uname)
);

