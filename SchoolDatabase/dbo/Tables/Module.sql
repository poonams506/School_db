CREATE TABLE [dbo].[Module] (
    [ModuleId] INT NOT NULL,
    [Name] NVARCHAR(250) NOT NULL,
    [ModuleKey] NVARCHAR(250) NULL,
    [ParentId] INT,
    [MenuTypeId] INT,
    [MenuUrl] NVARCHAR(250),
    [MenuIcon]  NVARCHAR(50),
    [MenuSort] INT DEFAULT ((0)) NOT NULL,
    [IsDeleted] BIT DEFAULT ((0)) NOT NULL,
    [CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
    CONSTRAINT [PKModule] PRIMARY KEY CLUSTERED ([ModuleId] ASC),

);

