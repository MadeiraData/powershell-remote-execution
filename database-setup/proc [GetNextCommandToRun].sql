CREATE PROCEDURE [dbo].[GetNextCommandToRun]
	@Computer sysname = NULL,
	@CommandId uniqueidentifier = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Q SET StartTimeUTC = GETUTCDATE()
	OUTPUT Inserted.ID
	     , Inserted.ScriptBlock
	FROM (
		SELECT TOP 1 *
		FROM [dbo].[CommandsQueue] WITH(READPAST)
		WHERE TargetComputer = ISNULL(@Computer,HOST_NAME())
		AND ([ID] = @CommandID OR StartTimeUTC IS NULL)
		ORDER BY QueuedDateUTC ASC
	) AS Q 
END