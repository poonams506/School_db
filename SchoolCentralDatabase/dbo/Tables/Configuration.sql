CREATE TABLE [dbo].[Configuration] (
    [ConfigurationId]               INT            IDENTITY (1, 1) NOT NULL,
    [ConfigurationName]             NVARCHAR (50) NOT NULL,
    [ConfigurationValue]            NVARCHAR (50) NOT NULL,
    [IsUpdateCheck] BIT NOT NULL DEFAULT(0), 
    CONSTRAINT [PKConfigurationId] PRIMARY KEY CLUSTERED ([ConfigurationId] ASC)
);

