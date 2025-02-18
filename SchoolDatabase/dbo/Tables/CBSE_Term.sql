CREATE TABLE [dbo].[CBSE_Term]
(
	TermId SMALLINT IDENTITY(1,1) NOT NULL,
	TermName NVARCHAR(200),
	CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT(0) NOT NULL,

		CONSTRAINT [PKCBSE_Term] PRIMARY KEY (TermId)

)
