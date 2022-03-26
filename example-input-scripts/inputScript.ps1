function Get-TimeStamp {
    Param(
    [switch]$NoWrap,
    [switch]$Utc
    )
    $dt = Get-Date
    if ($Utc -eq $true) {
        $dt = $dt.ToUniversalTime()
    }
    $str = "{0:MM/dd/yy} {0:HH:mm:ss}" -f $dt

    if ($NoWrap -ne $true) {
        $str = "[$str]"
    }
    return $str
}

Write-Output "$(Get-TimeStamp) Hello there."

for ($i = 0 ; $i -lt $args.Count ; $i++)
{
    Write-Output "Processing Argument $($i): $($args[$i])"
}

Write-Output "The script file I am running is: $($MyInvocation.MyCommand.Source)"

<#
$NewScriptBody = 'Write-Output "This is the new script. I live here now."'

Set-Content -Path $MyInvocation.MyCommand.Source -Value $NewScriptBody
#>