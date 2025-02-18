CREATE TABLE [dbo].[SharedTransportSchool]
(
	[SharedTransportSchoolId] BIGINT IDENTITY(1, 1),
	[Guid] uniqueidentifier NOT NULL,
	SchoolCode NVARCHAR(15)NOT NULL, 
	[IsDeleted] BIT DEFAULT ((0)) NOT NULL,
    [CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
    CONSTRAINT [PKSharedTransportSchoolId] PRIMARY KEY CLUSTERED ([SharedTransportSchoolId] ASC)

)
