﻿CREATE TABLE [dbo].[CreativeMatch] (
    [GK]                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [TypeID]                  INT             NULL,
    [Parent_type]             INT             NULL,
    [Parent_gk]               BIGINT          NOT NULL,
    [Creative_type]           INT             NULL,
    [Creative_gk]             BIGINT          NULL,
    [CreativeDefinition_type] INT             NULL,
    [CreativeDefinition_gk]   BIGINT          NULL,
    [AccountID]               INT             NOT NULL,
    [ChannelID]               INT             NULL,
    [OriginalID]              NVARCHAR (100)  NULL,
    [Status]                  INT             NULL,
    [DestinationUrl]          NVARCHAR (1000) NULL,
    [int_Field1]              INT             NULL,
    [int_Field2]              INT             NULL,
    [int_Field3]              INT             NULL,
    [int_Field4]              INT             NULL,
    [string_Field1]           NVARCHAR (1000) NULL,
    [string_Field2]           NVARCHAR (1000) NULL,
    [string_Field3]           NVARCHAR (1000) NULL,
    [string_Field4]           NVARCHAR (1000) NULL,
    [float_Field1]            DECIMAL (18, 3) NULL,
    [float_Field2]            DECIMAL (18, 3) NULL,
    [float_Field3]            DECIMAL (18, 3) NULL,
    [float_Field4]            DECIMAL (18, 3) NULL,
    [obj_Field4_gk]           BIGINT          NULL,
    [obj_Field1_type]         INT             NULL,
    [obj_Field1_gk]           BIGINT          NULL,
    [obj_Field2_type]         INT             NULL,
    [obj_Field2_gk]           BIGINT          NULL,
    [obj_Field3_type]         INT             NULL,
    [obj_Field3_gk]           BIGINT          NULL,
    [obj_Field4_type]         INT             NULL,
    [obj_Field5_gk]           BIGINT          NULL,
    [obj_Field5_type]         INT             NULL,
    [obj_Field6_gk]           BIGINT          NULL,
    [obj_Field6_type]         INT             NULL,
    [obj_Field7_gk]           BIGINT          NULL,
    [obj_Field7_type]         INT             NULL,
    [obj_Field8_gk]           BIGINT          NULL,
    [obj_Field8_type]         INT             NULL,
    [obj_Field9_gk]           BIGINT          NULL,
    [obj_Field9_type]         INT             NULL,
    [obj_Field10_gk]          BIGINT          NULL,
    [obj_Field10_type]        INT             NULL,
    [LastUpdated]             DATETIME        NULL,
    CONSTRAINT [PK_CreativeMatch] PRIMARY KEY CLUSTERED ([GK] ASC),
    CONSTRAINT [FK_CreativeMatch_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID]),
    CONSTRAINT [FK_CreativeMatch_CreativeDefinition] FOREIGN KEY ([CreativeDefinition_gk]) REFERENCES [dbo].[CreativeDefinition] ([GK]),
    CONSTRAINT [FK_CreativeMatch_EdgeType] FOREIGN KEY ([Parent_type]) REFERENCES [dbo].[MD_EdgeType] ([TypeID]),
    CONSTRAINT [FK_CreativeMatch_EdgeType1] FOREIGN KEY ([Creative_type]) REFERENCES [dbo].[MD_EdgeType] ([TypeID]),
    CONSTRAINT [FK_CreativeMatch_EdgeType2] FOREIGN KEY ([CreativeDefinition_type]) REFERENCES [dbo].[MD_EdgeType] ([TypeID])
);
