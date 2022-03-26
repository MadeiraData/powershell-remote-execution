CREATE TABLE [dbo].[CommandsQueue](
	[ID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_CommandsQueue_ID] DEFAULT (NEWSEQUENTIALID()),
	[Alias] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetComputer] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ScriptBlock] [nvarchar](MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[QueuedDateUTC] [datetime] NOT NULL CONSTRAINT [DF_CommandsQueue_QueuedDate] DEFAULT (GETUTCDATE()),
	[StartTimeUTC] [datetime] NULL,
	[EndTimeUTC] [datetime] NULL,
	[Output] [nvarchar](MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Notes] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CONSTRAINT [PK_CommandsQueue] PRIMARY KEY CLUSTERED ([ID] ASC)
)
GO

CREATE NONCLUSTERED INDEX IX_NextInQueue ON [dbo].[CommandsQueue]
(TargetComputer, QueuedDateUTC)
INCLUDE(ID, ScriptBlock, StartTimeUTC)
WHERE StartTimeUTC IS NULL
GO