CREATE TABLE [dbo].[UserRole] (
    [UserRoleId] INT NOT NULL IDENTITY(1,1),
    [UserId] INT NOT NULL,
    [RoleId] INT NOT NULL,
    [RefId] INT NULL,
    [IsDeleted] BIT DEFAULT ((0)) NOT NULL,
    [CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
    CONSTRAINT [PKUserRole] PRIMARY KEY CLUSTERED ([UserRoleId] ASC)
);

