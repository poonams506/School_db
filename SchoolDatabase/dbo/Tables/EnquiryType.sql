CREATE TABLE [dbo].[EnquiryType]
(
	[EnquiryTypeId] INT NOT NULL,
	[EnquiryTypeName] NVARCHAR(200),
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKEnquiryType] PRIMARY KEY CLUSTERED ([EnquiryTypeId] ASC),
)
