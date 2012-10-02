CREATE TABLE [dbo].[Channel] (
    [ID]          INT           NOT NULL,
    [Name]        NVARCHAR (50) NOT NULL,
    [ChannelType] INT           NULL,
    CONSTRAINT [PK_Channel] PRIMARY KEY CLUSTERED ([ID] ASC)
);

