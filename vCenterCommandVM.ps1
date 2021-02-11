Function WaitJob { Get-Job | Wait-Job }

Function vCenterCommandVM
{
	param (
		[switch]$Force = $False,
		[switch]$IgnoreErrors = $False,
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $false)]
		[string]$Session,
		[Parameter(Mandatory = $false)]
		[string]$VMSession,
		[Parameter(Mandatory = $false)]
		[string]$VMname,
		[Parameter(Mandatory = $false)]
		[string]$VMuser,
		[Parameter(Mandatory = $false)]
		[string]$VMpass,
		[Parameter(Mandatory = $false)]
		[string]$ScriptType,
		[Parameter(Mandatory = $true)]
		[string]$Script
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	$VM = Get-VM -Name $VMname
	$VMOS = ($VM).guest.OSFullName
	. "$PSScriptRoot\vCenterStoragePassword.ps1" <# Config file for passwords #>
	if ([string]::IsNullOrEmpty($VMuser)) { $VMuser = $VMdefualt.User } <# If user string is empty use default user, lines order need to be between two passwords files #>
	if ([string]::IsNullOrEmpty($VMpass)) { $VMpass = $VMdefualt.Pass } <# If password string is empty use default password, lines order need to be between two passwords files #>
	. "$PSScriptRoot\vCenterStoragePassword.ps1" <# Config file for passwords again, do not remove #>
	
	if ([string]::IsNullOrEmpty($ScriptType))
	{
		if ($VMOS -like "*Win*") { $ScriptType = "PowerShell" }
		if ($VMOS -like "*Linux*") { $ScriptType = "Bash" }
	}
	
	if ($Output -eq "True") { $ErrorActionPreference = 'Continue' } <# Continue on errors #>
	else { $ErrorActionPreference = 'SilentlyContinue' } <# SilentlyContinue on errors #>
	if ([bool]$IgnoreErrors -eq "True") { $ErrorActionPreference = 'Ignore' } <# Ignore on errors #>
	
	if ([bool]$Force -eq "True")
	{
		. "$PSScriptRoot\vCenterVMtools.ps1"
		vCenterVMtools -Session $Session -VMSession $VMSession -VMname $VMname -Output $Output -Force | WaitJob <# Power on the VM if forced #>
	}
	
	foreach ($Cred in $Creds) <# Login to the VM using the provided creds or the cred file, and send command #>
	{
		if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, running the script using creds, user: $($Cred.User), password: $($Cred.Pass)" } <# If output is true #>
		try
		{
			if ($Output -eq "True") { Invoke-VMScript -VM $VMname -GuestUser $Cred.User -GuestPassword $Cred.Pass -ScriptText $Script -ScriptType $ScriptType | WaitJob } <# If output is true #>
			else { Invoke-VMScript -VM $VMname -GuestUser $Cred.User -GuestPassword $Cred.Pass -ScriptText $Script -ScriptType $ScriptType | out-null | WaitJob}
			break
		}
		catch [VMware.VimAutomation.ViCore.Types.V1.ErrorHandling.InvalidGuestLogin] { if ($Output -eq "True") { Write-Host "Invalid credential $($Cred.User)" }} <# If output is on #>
		catch { $out = "Other error for $($Cred.User)" }
	}
}