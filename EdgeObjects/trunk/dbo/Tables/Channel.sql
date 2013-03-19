CREATE TABLE [dbo].[Channel] (
    [ID]          INT            NOT NULL,
    [Name]        NVARCHAR (50)  NOT NULL,
    [DisplayName] NVARCHAR (100) NULL,
    [ChannelType] INT            NULL,
    CONSTRAINT [PK_Channel] PRIMARY KEY CLUSTERED ([ID] ASC)
);



