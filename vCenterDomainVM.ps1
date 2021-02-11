Function WaitJob { Get-Job | Wait-Job }

Function vCenterDomainVM
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $false)]
		[string]$Session,
		[Parameter(Mandatory = $false)]
		[string]$VMSession,
		[Parameter(Mandatory = $false)]
		[string]$VMname,
		[Parameter(Mandatory = $true)]
		[string]$VMuser,
		[Parameter(Mandatory = $true)]
		[string]$VMpass,
		[Parameter(Mandatory = $true)]
		[string]$LocalPass
	)
	
	if (-not [string]::IsNullOrEmpty($Session) -and -not [string]::IsNullOrEmpty($VMSession)) { $VMname = $Session + '-' + $VMSession }
	
}


. "$PSScriptRoot\vCenterPowerVM.ps1"
vCenterPowerVM -Session $Session -VMSession $VMSession -VMname $VMname -Power "Restart"

$ScriptType = "PowerShell"
$Script = Install-windowsfeature -Name AD-Domain-Services -IncludeManagementTools -Restart:$false -Confirm:$false

. "$PSScriptRoot\vCenterCommandVM.ps1"
vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -VMuser $VMuser -VMpass $VMpass -ScriptType $ScriptType -Script $Script

$SecurePassword = ConvertTo-SecureString $PlainPassword -AsPlainText -Force
$InstallDomain = Install-ADDSForest -DomainName "testdomain.local" -SafeModeAdministratorPassword $SecurePassword -SkipPreChecks -InstallDNS -NoRebootOnCompletion -Force -Confirm:$false
$InstallDomain




[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('JABTAGUAYwB1AHIAZQBQAGEAcwBzAHcAbwByAGQAIAA9ACAAQwBvAG4AdgBlAHIAdABUAG8ALQBTAGUAYwB1AHIAZQBTAHQAcgBpAG4AZwAgACQAUABsAGEAaQBuAFAAYQBzAHMAdwBvAHIAZAAgAC0AQQBzAFAAbABhAGkAbgBUAGUAeAB0ACAALQBGAG8AcgBjAGUA'))
