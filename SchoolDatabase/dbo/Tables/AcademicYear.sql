CREATE TABLE [dbo].[AcademicYear]
(
	[AcademicYearId] SMALLINT NOT NULL,
	[AcademicYearName] NVARCHAR(10) NOT NULL,
	[AcademicYearKey] NVARCHAR(10) NOT NULL,
	CONSTRAINT [PKAcademicYear] PRIMARY KEY CLUSTERED ([AcademicYearId] ASC)
)
