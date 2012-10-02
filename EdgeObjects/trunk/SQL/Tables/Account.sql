CREATE TABLE [dbo].[Account] (
    [ID]              INT           NOT NULL,
    [Name]            NVARCHAR (50) NOT NULL,
    [ParentAccountID] INT           NULL,
    [Status]          TINYINT       NULL,
    CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_Account_Account] FOREIGN KEY ([ParentAccountID]) REFERENCES [dbo].[Account] ([ID])
);

