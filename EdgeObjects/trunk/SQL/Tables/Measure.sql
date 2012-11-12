CREATE TABLE [dbo].[Measure] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [Name]               NVARCHAR (50) NOT NULL,
    [MeasureDataType]    INT           NULL,
    [ChannelID]          INT           NULL,
    [AccountID]          INT           NULL,
    [DisplayName]        NVARCHAR (50) NULL,
    [StringFormat]       NVARCHAR (50) NULL,
    [InheritedByDefault] BIT           NULL,
    [OptionsOverride]    BIT           CONSTRAINT [DF_Measure_OptionsOverride] DEFAULT ((0)) NULL,
    [Options]            BIGINT        NULL,
    CONSTRAINT [PK_Measure] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [CK_Measure_InheritedByDefault] CHECK NOT FOR REPLICATION ([AccountID] IS NULL AND [InheritedByDefault] IS NOT NULL OR [AccountID] IS NOT NULL AND [InheritedByDefault] IS NULL),
    CONSTRAINT [FK_Measure_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_Measure_Channel] FOREIGN KEY ([ChannelID]) REFERENCES [dbo].[Channel] ([ID])
);


GO
ALTER TABLE [dbo].[Measure] NOCHECK CONSTRAINT [CK_Measure_InheritedByDefault];




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'InheritedByDefault must be defined for measure definitions (but not for account measures).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Measure', @level2type = N'CONSTRAINT', @level2name = N'CK_Measure_InheritedByDefault';


GO


