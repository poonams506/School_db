CREATE TABLE [dbo].[RolePermission] (
    [RolePermissionId] BIGINT NOT NULL IDENTITY(1,1),
    [RoleId] INT NOT NULL,
    [PermissionId] INT NOT NULL,
    [ModuleId] INT NOT NULL,
    [IsDeleted] BIT DEFAULT ((0)) NOT NULL,
    [CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
    CONSTRAINT [PKRolePermission] PRIMARY KEY CLUSTERED ([RolePermissionId] ASC),
    CONSTRAINT [FKRolePermissionRole] FOREIGN KEY (RoleId) REFERENCES Role(RoleId),
    CONSTRAINT [FKRolePermissionModule] FOREIGN KEY (ModuleId) REFERENCES Module(ModuleId),
    CONSTRAINT [FKRolePermissionPermission] FOREIGN KEY (PermissionId) REFERENCES Permission(PermissionId)
);
