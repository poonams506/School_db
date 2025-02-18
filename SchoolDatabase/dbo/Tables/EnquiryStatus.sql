CREATE TABLE [dbo].[EnquiryStatus]
(
	[EnquiryStatusId] INT NOT NULL,
	[EnquiryStatusName] NVARCHAR(200),
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKEnquiryStatus] PRIMARY KEY CLUSTERED ([EnquiryStatusId] ASC),
)
