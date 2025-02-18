CREATE TABLE [dbo].[ExceptionLog] (
    [ExceptionLogId]                INT            IDENTITY (1, 1) NOT NULL,
    [ErrorLine]        INT            NULL,
    [ErrorMessage]     NVARCHAR (MAX) NULL,
    [ErrorNumber]      INT            NULL,
    [ErrorProcedure]   NVARCHAR (500) NULL,
    [ErrorSeverity]    INT            NULL,
    [ErrorState]       INT            NULL,
    [ErrorRaisedDate] DATETIME       NULL,
    CONSTRAINT [PKExceptionLog] PRIMARY KEY CLUSTERED ([ExceptionLogId] ASC)
);

