param(
 [string]$Computer = $env:computername
,[string]$CommandID
,[string]$RepositoryServer = "."
,[string]$RepositoryDatabase = "RemoteExecution"
,[string]$RepositoryConnectionStringTemplate = "Data Source={0};Database={1};Encrypt=True;TrustServerCertificate=True;Integrated Security=True;Application Name=Powershell Remote Execution"
)

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

$Query = "EXEC [dbo].[GetNextCommandToRun] @Computer"
$conn=New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = $RepositoryConnectionStringTemplate -f $RepositoryServer, $RepositoryDatabase
$conn.ConnectionString=$ConnectionString
$conn.Open()
$cmd=New-Object system.Data.SqlClient.SqlCommand($Query,$conn)
$cmd.Parameters.Add("@Computer", [System.Data.SqlDbType]::NVarChar, 256).Value = $Computer

if ($CommandID -ne $null -and $CommandID -ne "")
{
    $Query = $Query + ", @CommandID"
    $cmd.Parameters.Add("@CommandID", [System.Data.SqlDbType]::UniqueIdentifier).Value = $CommandID
}

$cmd.CommandText = $Query
#$cmd.CommandTimeout=$QueryTimeout
$ds=New-Object system.Data.DataSet
$da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.fill($ds)

if ($ds.Tables[0].Rows.Count -eq 0) {
    Write-Output "No commands to execute."
}

foreach ($r in $ds.Tables[0].Rows) {
    Write-Output "Running command: $($r.ID)"

    if ($r.ScriptBlock) {

        #region get scriptblock parameters/arguments
        $CommandParams = Invoke-Sqlcmd -Query "EXEC [dbo].[GetCommandArguments] '$($r.ID)'" -ServerInstance $RepositoryServer -Database $RepositoryDatabase
        $ScriptBlockArgs = @()

        $CommandParams | ForEach-Object {
            Write-Verbose "Received Argument $($_.Position): $($_.ArgumentValue)"
            $ScriptBlockArgs += $_.ArgumentValue
        }
        #endregion get scriptblock parameters/arguments

        # Run the dynamic scriptblock:
        Invoke-Command -ScriptBlock $([scriptblock]::Create($r.ScriptBlock)) -OutVariable CommandOutput -ArgumentList $ScriptBlockArgs

        #region mark command as completed
        $Query = "EXEC [dbo].[FinishCommandExecution] @Computer, @CommandID, @CommandOutput"
        $cmd=New-Object system.Data.SqlClient.SqlCommand($Query,$conn)

        $cmd.Parameters.Add("@Computer", [System.Data.SqlDbType]::NVarChar, 256).Value = $Computer
        $cmd.Parameters.Add("@CommandID", [System.Data.SqlDbType]::UniqueIdentifier).Value = $r.ID

        # This concatenates all output messages from the execution and delimits them with an end-line:
        $cmd.Parameters.Add("@CommandOutput", [System.Data.SqlDbType]::NVarChar, -1).Value = $CommandOutput -join "`n"

        $cmd.ExecuteNonQuery() | Out-Null

        #endregion mark command as completed
    } else {
        Write-Host "Nothing to run."
    }
}

$conn.Dispose()
$cmd.Dispose()