CREATE TABLE [dbo].[Schedulers] (
    [Name]                      NVARCHAR (50)  NOT NULL,
    [EndPointConfigurationName] NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Schedulers] PRIMARY KEY CLUSTERED ([Name] ASC, [EndPointConfigurationName] ASC)
);

