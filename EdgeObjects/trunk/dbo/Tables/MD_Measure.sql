CREATE TABLE [dbo].[MD_Measure] (
    [ID]              INT           IDENTITY (1, 1) NOT NULL,
    [AccountID]       INT           CONSTRAINT [DF_MD_Measure_AccountID] DEFAULT ((-1)) NOT NULL,
    [Name]            NVARCHAR (50) NOT NULL,
    [DataType]        INT           NULL,
    [DisplayName]     NVARCHAR (50) NULL,
    [StringFormat]    NVARCHAR (50) NULL,
    [Options]         INT           CONSTRAINT [DF_MD_Measure_Options] DEFAULT ((0)) NULL,
    [OptionsOverride] BIT           NULL,
    CONSTRAINT [PK_Measure] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_Measure_Account] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Measure_Name]
    ON [dbo].[MD_Measure]([AccountID] ASC, [Name] ASC);

