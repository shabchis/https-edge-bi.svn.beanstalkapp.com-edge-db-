CREATE TABLE [dbo].[ServiceInstance] (
    [InstanceID]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountID]        INT            NOT NULL,
    [ParentInstanceID] BIGINT         NULL,
    [ServiceName]      NVARCHAR (100) NOT NULL,
    [TimeScheduled]    DATETIME       NULL,
    [TimeStarted]      DATETIME       NULL,
    [TimeEnded]        DATETIME       NULL,
    [Priority]         INT            NOT NULL,
    [State]            INT            NOT NULL,
    [Progress]         FLOAT (53)     NOT NULL,
    [Outcome]          INT            NOT NULL,
    [ServiceUrl]       NVARCHAR (100) NULL,
    [Configuration]    XML            NOT NULL,
    [ActiveRule]       XML            NULL
);



