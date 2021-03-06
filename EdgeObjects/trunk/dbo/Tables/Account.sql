﻿CREATE TABLE [dbo].[Account] (
    [ID]              INT           NOT NULL,
    [Name]            NVARCHAR (50) NOT NULL,
    [ParentAccountID] INT           NULL,
    [Status]          INT           CONSTRAINT [DF_Account_Status] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_Account_ParentAccount] FOREIGN KEY ([ParentAccountID]) REFERENCES [dbo].[Account] ([ID])
);





