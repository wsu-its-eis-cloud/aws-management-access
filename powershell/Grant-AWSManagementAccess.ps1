param(
    [Alias("se")]
    [string] $sessionName = "awsDefaultSession",

    [Alias("f")]
    [string] $serviceFamily = "",

    [Alias("ft")]
    [string] $serviceFamilyTagName = "service-family",

    [Alias("i")]
    [string] $serviceId  = "",

    [Alias("it")]
    [string] $serviceIdTagName = "service-id",

    [Alias("a")]
    [string[]] $applicationNames = @(),

    [Alias("pi")]
    [switch] $publicIp = $false,

    [Alias("d")]
    [switch] $debug = $false,

    [Alias("h")]
    [switch] $help = $false
)

if ($help) {
	Write-Output "`t Allow management access to a specified service"
	Write-Output "`t Prerequisites: Powershell"
	Write-Output "`t "
	Write-Output "`t Parameters:"
	Write-Output "`t "
	Write-Output "`t serviceFamily"
	Write-Output "`t     The name of the service family."
	Write-Output ("`t     Default: {0}" -f $serviceFamily)
    Write-Output "`t     Alias: sf"
	Write-Output "`t     Example: ./aws_grant_mssql.ps1 -serviceFamily database-hosting"
    Write-Output "`t     Example: ./aws_grant_mssql.ps1 -s database-hosting"
	
    Write-Output "`t "
	Write-Output "`t serviceFamilyTagName"
	Write-Output "`t     The name of the tag that stores the service family name"
	Write-Output ("`t     Default: {0}" -f $serviceFamilyTagName)
    Write-Output "`t     Alias: t"
	Write-Output "`t     Example: ./aws_grant_mssql.ps1 -serviceFamilyTagName service-family"
    Write-Output "`t     Example: ./aws_grant_mssql.ps1 -t service-family"

    Write-Output "`t "
	Write-Output "`t serviceId"
	Write-Output "`t     The name of the tag that stores the service family name"
	Write-Output ("`t     Default: {0}" -f $serviceId)
    Write-Output "`t     Alias: si"
	Write-Output "`t     Example: ./aws_grant_mssql.ps1 -serviceId s1234567"
    Write-Output "`t     Example: ./aws_grant_mssql.ps1 -i s1234567"

    Write-Output "`t "
	Write-Output "`t serviceIdTagName"
	Write-Output "`t     The name of the tag that stores the service id"
	Write-Output ("`t     Default: {0}" -f $serviceIdTagName)
    Write-Output "`t     Alias: ti"
	Write-Output "`t     Example: ./aws_grant_mssql.ps1 -serviceIdTagName service-id"
    Write-Output "`t     Example: ./aws_grant_mssql.ps1 -ti service-id"

    Write-Output "`t "
	Write-Output "`t debug"
	Write-Output "`t     If set, a transcript of the session will be recorded."
	Write-Output ("`t     Default: {0}" -f $debug)
    Write-Output "`t     Alias: ti"
	Write-Output "`t     Example: ./aws_grant_mssql.ps1 -serviceIdTagName service-id"
    Write-Output "`t     Example: ./aws_grant_mssql.ps1 -ti service-id"

    return
}

# Prompt for name if not specified
if ($serviceFamily -eq "") {
	$serviceFamily = Read-Host "Enter the name of the service family"
}
$serviceFamily = $serviceFamily.ToLower()

# Prompt for name if not specified
if ($serviceFamilyTagName -eq "") {
	$serviceFamilyTagName = Read-Host "Enter the name of the tag that contains the service family in your environment"
}
$serviceFamilyTagName = $serviceFamilyTagName.ToLower()

# Prompt for name if not specified
if ($serviceId -eq "") {
	$serviceId = Read-Host "Enter the value of the service id"
}
$serviceId = $serviceId.ToLower()

# Prompt for name if not specified
if ($serviceIdTagName -eq "") {
	$serviceIdTagName = Read-Host "Enter the name of the tag that contains the service id in your environment"
}
$serviceIdTagName = $serviceIdTagName.ToLower()

# navigate to library root
cd $PSScriptRoot

# load necessary modules
.\import-required-modules.ps1

if($debug) {
    $DebugPreference = "Continue"
    $transcriptName = ("{0}-{1}.txt" -f $MyInvocation.MyCommand.Name, [DateTimeOffset]::Now.ToUnixTimeSeconds())
    Start-Transcript -Path $transcriptName

    $serviceFamily
    $serviceFamilyTagName
    $serviceId
    $serviceIdTagName
}

git clone https://github.com/wsu-its-eis-cloud/aws-api-session-management.git
git clone https://github.com/wsu-its-eis-cloud/aws-sg-access.git

invoke-expression -Command aws-api-session-management\powershell\New-AWSMfaStsSession.ps1
cd $PSScriptRoot

invoke-expression -Command ("aws-sg-access\powershell\Grant-AWSSecurityGroupAccess.ps1 -serviceFamily {0} -serviceId {1} -applicationNames {2}" -f $serviceFamily, $serviceId, ($applicationNames -join ","))
cd $PSScriptRoot

if($debug) {
    Stop-Transcript
    $DebugPreference = "SilentlyContinue"
}