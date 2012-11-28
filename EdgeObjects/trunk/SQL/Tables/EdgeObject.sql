CREATE TABLE [dbo].[EdgeObject] (
    [GK]             BIGINT          IDENTITY (1000, 1) NOT NULL,
    [ObjectType]     NVARCHAR (50)   NOT NULL,
    [AccountID]      INT             NOT NULL,
    [ChannelID]      INT             NULL,
    [OriginalID]     NVARCHAR (100)  NULL,
    [Name]           NVARCHAR (50)   NULL,
    [Status]         INT             NULL,
    [int_Field1]     INT             NULL,
    [int_Field2]     INT             NULL,
    [int_Field3]     INT             NULL,
    [int_Field4]     INT             NULL,
    [string_Field1]  NVARCHAR (1000) NULL,
    [string_Field2]  NVARCHAR (1000) NULL,
    [string_Field3]  NVARCHAR (1000) NULL,
    [string_Field4]  NVARCHAR (1000) NULL,
    [Decimal_Field1] DECIMAL (18)    NULL,
    CONSTRAINT [PK_ChannelObject_1] PRIMARY KEY CLUSTERED ([GK] ASC),
    CONSTRAINT [FK_SegmentObject_Channel] FOREIGN KEY ([ChannelID]) REFERENCES [dbo].[Channel] ([ID]),
    CONSTRAINT [FK_SegmentObject_Channel1] FOREIGN KEY ([ChannelID]) REFERENCES [dbo].[Channel] ([ID])
);


GO
ALTER TABLE [dbo].[EdgeObject] NOCHECK CONSTRAINT [FK_SegmentObject_Channel];


GO
ALTER TABLE [dbo].[EdgeObject] NOCHECK CONSTRAINT [FK_SegmentObject_Channel1];




GO
ALTER TABLE [dbo].[EdgeObject] NOCHECK CONSTRAINT [FK_SegmentObject_Channel];


GO
ALTER TABLE [dbo].[EdgeObject] NOCHECK CONSTRAINT [FK_SegmentObject_Channel1];




GO
ALTER TABLE [dbo].[EdgeObject] NOCHECK CONSTRAINT [FK_SegmentObject_Channel];


GO
ALTER TABLE [dbo].[EdgeObject] NOCHECK CONSTRAINT [FK_SegmentObject_Channel1];

