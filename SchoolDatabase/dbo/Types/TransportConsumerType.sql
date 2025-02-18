CREATE TYPE [dbo].[TransportConsumerType] AS TABLE(
	[TransportConsumerStoppageMappingId] [INT] NULL,
	[RoleId] [INT] NULL,
	[ConsumerId] [INT] NULL,
	[StoppageId] [BIGINT] NULL,
	[AcademicYearId] [INT] NULL,
	[FromDate] [DATETIME] NULL,
	[ToDate] [DATETIME] NULL,
	[PickDropId] [INT] NULL,
	[PickDropPrice] [FLOAT] NULL
)
GO;