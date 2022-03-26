<#
.DESCRIPTION
Use this script to easily "import" a new Powershell script to be executed remotely.

#>
param(
[Parameter(Mandatory = $true,
            ParameterSetName = 'DirectScriptBlock',
            HelpMessage = 'Please enter a Powershell scriptblock to be executed remotely')]
 [string]$ScriptBlock
,
 [Parameter(Mandatory = $true,
            ParameterSetName = 'ImportScriptFile',
            HelpMessage = 'Please enter a Powershell script file to import and be executed remotely')]
 [string]$ScriptInputFile
,[string]$TargetComputer = $env:computername
,[string]$Alias
,[string]$Notes
,[string]$CommandID
,[string[]]$Arguments = @()
#,[string[]]$Arguments = @("Eitan", "Blumin") #Example
#,[string]$ScriptInputFile = "inputScript.ps1" #Example
,[string]$RepositoryServer = "."
,[string]$RepositoryDatabase = "RemoteExecution"
,[string]$RepositoryConnectionStringTemplate = "Data Source={0};Database={1};Encrypt=True;TrustServerCertificate=True;Integrated Security=True;Application Name=Powershell Remote Management"
)
$ErrorActionPreference = "Stop"

if($CommandID -ne $null -and $CommandID -ne ""){
    try{
        $ObjectGuid = [System.Guid]::New($CommandID)
        if($ObjectGuid -eq [System.Guid]::Empty) {
            Write-Error "Parameter CommandID is an invalid Guid" -ErrorAction Stop
        }
    }
    catch
    {
            Write-Error "Parameter CommandID is an invalid Guid" -ErrorAction Stop
    }
}

if ($ScriptInputFile) {
    if (-not (Test-Path -Path $ScriptInputFile)) {
        Write-Error "Script Input File was not found or not accessible: $ScriptInputFile" -ErrorAction Stop
    }
    else {
        $filestream = (Get-Item -Path $ScriptInputFile -ErrorAction Stop).OpenText()
        $ScriptBlock = $filestream.ReadToEnd()
        $filestream.Close()
    }
}

$ScriptBlockCmd = $([scriptblock]::Create($ScriptBlock)) #attempt conversion to validate

$scon = New-Object System.Data.SqlClient.SqlConnection
$scon.ConnectionString = $RepositoryConnectionStringTemplate -f $RepositoryServer, $RepositoryDatabase

$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.Connection = $scon
$cmd.CommandTimeout = 40

if ($CommandID -ne $null -and $CommandID -ne "")
{
    $cmd.CommandText = "INSERT INTO [dbo].[CommandsQueue]([ID],[Alias],[TargetComputer],[ScriptBlock],[Notes]) OUTPUT inserted.ID VALUES(@ID,@Alias,@TargetComputer,@ScriptBlock,@Notes)"
    $cmd.Parameters.Add("@ID", [System.Data.SqlDbType]::UniqueIdentifier).Value = $CommandID
}
else
{
    $cmd.CommandText = "INSERT INTO [dbo].[CommandsQueue]([Alias],[TargetComputer],[ScriptBlock],[Notes]) OUTPUT inserted.ID VALUES(@Alias,@TargetComputer,@ScriptBlock,@Notes)"
}

$cmd.Parameters.Add("@Alias", [System.Data.SqlDbType]::NVarChar, 256).Value = $Alias
$cmd.Parameters.Add("@TargetComputer", [System.Data.SqlDbType]::NVarChar, 256).Value = $TargetComputer
$cmd.Parameters.Add("@ScriptBlock", [System.Data.SqlDbType]::NVarChar, -1).Value = $ScriptBlock
$cmd.Parameters.Add("@Notes", [System.Data.SqlDbType]::NVarChar, -1).Value = $Notes

try
{
    $scon.Open()
    $CommandID = $cmd.ExecuteScalar()
    Write-Output "Command queued: $CommandID"

    if ($Arguments.Count -gt 0) {

        $pos = 0
        $Arguments | ForEach-Object{
            Write-Output "Adding Argument $($pos): $($_)"

            $cmd.Dispose()
            $cmd = New-Object System.Data.SqlClient.SqlCommand
            $cmd.Connection = $scon
            $cmd.CommandTimeout = 40
            $cmd.CommandText = "INSERT INTO [dbo].[CommandArguments]([CommandID],[Position],[ArgumentValue]) VALUES (@CommandID, @Position, @ArgumentValue)"
            $cmd.Parameters.Add("@CommandID", [System.Data.SqlDbType]::UniqueIdentifier).Value = $CommandID
            $cmd.Parameters.Add("@Position", [System.Data.SqlDbType]::Int).Value = $pos
            $cmd.Parameters.Add("@ArgumentValue", [System.Data.SqlDbType]::NVarChar, -1).Value = $_
            $cmd.ExecuteNonQuery() | Out-Null
            $pos++
        }
    }
}
catch [Exception]
{
    Write-Warning "Error while saving command to database: $($_.Exception.Message)"
}
finally
{
    $scon.Dispose()
    $cmd.Dispose()
}