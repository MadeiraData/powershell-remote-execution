CREATE TABLE [dbo].[CommandArguments](
	[ID] [uniqueidentifier] NOT NULL,
	[CommandID] [uniqueidentifier] NOT NULL,
	[Position] [int] NOT NULL,
	[ArgumentValue] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Notes] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_CommandArguments] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CommandArguments] ADD  CONSTRAINT [DF_CommandArguments_ID]  DEFAULT (NEWSEQUENTIALID()) FOR [ID]
GO

ALTER TABLE [dbo].[CommandArguments] ADD CONSTRAINT [FK_CommandArguments_CommandsQueue] FOREIGN KEY
(CommandID) REFERENCES [dbo].[CommandsQueue](ID) ON DELETE CASCADE;
GO


