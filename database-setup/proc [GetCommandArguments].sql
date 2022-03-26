CREATE PROCEDURE [dbo].[GetCommandArguments]
	@CommandId uniqueidentifier = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT Position, ArgumentValue
	FROM [dbo].[CommandArguments]
	WHERE CommandID = @CommandId
	ORDER BY Position ASC
END