CREATE TABLE [dbo].[UserResetPassword] (
    [UserResetPasswordId]            INT            IDENTITY (1, 1) NOT NULL,
    [UserId] INT,
    [Token] NVARCHAR(150),
    [ExpirationDate] DATETIME,
    [IsDeleted]    BIT            DEFAULT ((0)) NOT NULL,
    [CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
    CONSTRAINT [PKUserResetPassword] PRIMARY KEY CLUSTERED ([UserResetPasswordId] ASC)
);

