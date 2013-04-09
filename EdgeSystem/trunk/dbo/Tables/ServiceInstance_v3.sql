﻿CREATE TABLE [dbo].[ServiceInstance_v3] (
    [InstanceID]                    CHAR (32)      NOT NULL,
    [ParentInstanceID]              CHAR (32)      NULL,
    [ProfileID]                     CHAR (32)      NULL,
    [ServiceName]                   NVARCHAR (100) NOT NULL,
    [Progress]                      FLOAT (53)     NOT NULL,
    [State]                         INT            NOT NULL,
    [Outcome]                       INT            NOT NULL,
    [TimeCreated]                   DATETIME       CONSTRAINT [DF_ServiceInstance_v3_TimeCreated] DEFAULT (getdate()) NOT NULL,
    [TimeInitialized]               DATETIME       NULL,
    [TimeStarted]                   DATETIME       NULL,
    [TimeEnded]                     DATETIME       NULL,
    [TimeLastPaused]                DATETIME       NULL,
    [TimeLastResumed]               DATETIME       NULL,
    [ResumeCount]                   INT            CONSTRAINT [DF_ServiceInstance_v3_ResumeCount] DEFAULT ((0)) NOT NULL,
    [Configuration]                 XML            NOT NULL,
    [Scheduling_Status]             INT            NULL,
    [Scheduling_Scope]              INT            NULL,
    [Scheduling_MaxDeviationBefore] BIGINT         NULL,
    [Scheduling_MaxDeviationAfter]  BIGINT         NULL,
    [Scheduling_RequestedTime]      DATETIME       NULL,
    [Scheduling_ExpectedStartTime]  DATETIME       NULL,
    [Scheduling_ExpectedEndTime]    DATETIME       NULL,
    [HostName]                      NVARCHAR (50)  NOT NULL,
    [HostGuid]                      CHAR (32)      NOT NULL,
    CONSTRAINT [PK_ServiceInstance_v3] PRIMARY KEY CLUSTERED ([InstanceID] ASC)
);

