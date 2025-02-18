CREATE TABLE [dbo].[Permission] (
    [PermissionId] INT NOT NULL,
    [Name] NVARCHAR(250) NOT NULL,
    [PermissionKey] NVARCHAR(250) NULL,
    [IsDeleted]    BIT            DEFAULT ((0)) NOT NULL,
    [CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
    CONSTRAINT [PKPermission] PRIMARY KEY CLUSTERED ([PermissionId] ASC)
);

