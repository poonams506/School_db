CREATE TYPE dbo.SubjectMasterIndexType AS TABLE
(
    SubjectMasterId BIGINT,
    IndexNumber NVARCHAR(3),
    SubjectName NVARCHAR(50)
);