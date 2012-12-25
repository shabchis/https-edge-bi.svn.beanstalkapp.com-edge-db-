CREATE TABLE [dbo].[EdgeObject] (
    [GK]            BIGINT          IDENTITY (1000, 1) NOT NULL,
    [TypeID]        INT             NOT NULL,
    [AccountID]     INT             NOT NULL,
    [ChannelID]     INT             NULL,
    [OriginalID]    NVARCHAR (100)  NULL,
    [Status]        INT             NULL,
    [int_Field1]    INT             NULL,
    [int_Field2]    INT             NULL,
    [int_Field3]    INT             NULL,
    [int_Field4]    INT             NULL,
    [string_Field1] NVARCHAR (1000) NULL,
    [string_Field2] NVARCHAR (1000) NULL,
    [string_Field3] NVARCHAR (1000) NULL,
    [string_Field4] NVARCHAR (1000) NULL,
    [float_Field1]  DECIMAL (18, 3) NULL,
    [float_Field2]  DECIMAL (18, 3) NULL,
    [float_Field3]  DECIMAL (18, 3) NULL,
    [float_Field4]  DECIMAL (18, 3) NULL,
    CONSTRAINT [PK_EdgeObject] PRIMARY KEY CLUSTERED ([GK] ASC),
    CONSTRAINT [FK_EdgeObject_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_EdgeObject_Channel] FOREIGN KEY ([ChannelID]) REFERENCES [dbo].[Channel] ([ID]),
    CONSTRAINT [FK_EdgeObject_EdgeType] FOREIGN KEY ([TypeID]) REFERENCES [dbo].[EdgeType] ([TypeID])
);


GO
ALTER TABLE [dbo].[EdgeObject] NOCHECK CONSTRAINT [FK_EdgeObject_Channel];




GO



GO





GO



GO





GO



GO


