CREATE TABLE [dbo].[Scheduling] (
    [RequestID]         CHAR (32)      NOT NULL,
    [UniqueKey]         NVARCHAR (400) NOT NULL,
    [RequestedTime]     DATETIME2 (7)  NOT NULL,
    [ExpectedStartTime] DATETIME2 (7)  NULL,
    [InstanceName]      NVARCHAR (400) NULL,
    [InstanceUses]      NVARCHAR (400) NOT NULL,
    [SchedulingScope]   NCHAR (10)     NOT NULL,
    [SchedulingStatus]  INT            NOT NULL,
    [LegacyInstanceID]  BIGINT         NULL,
    [Outcome]           INT            NULL,
    CONSTRAINT [PK_Scheduling] PRIMARY KEY CLUSTERED ([RequestID] ASC)
);

