﻿CREATE TABLE [dbo].[MonthMaster]
(
	[MonthMasterId] SMALLINT NOT NULL,
	[MonthName] NVARCHAR(20) NOT NULL,
	[MonthNameKey] NVARCHAR(20) NULL,
	[SortBy] SMALLINT NOT NULL,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKMonthMaster] PRIMARY KEY CLUSTERED ([MonthMasterId] ASC)
)
