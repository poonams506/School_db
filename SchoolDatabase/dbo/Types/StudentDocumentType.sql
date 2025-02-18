CREATE TYPE [dbo].[StudentDocumentType] AS TABLE
(
    DocumentId BIGINT,
    DocumentName NVARCHAR(50),
    DocumentUrl NVARCHAR(100),
    DocumentFileType NVARCHAR(50)
)
