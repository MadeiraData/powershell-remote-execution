CREATE PROCEDURE [dbo].[FinishCommandExecution]
	@Computer sysname = NULL,
	@CommandId uniqueidentifier = NULL,
	@CommandOutput nvarchar(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Q SET EndTimeUTC = GETUTCDATE(), [Output] = @CommandOutput
	FROM [dbo].[CommandsQueue] AS Q
	WHERE TargetComputer = ISNULL(@Computer, HOST_NAME())
	AND ID = @CommandID
END