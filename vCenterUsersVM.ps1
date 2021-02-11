Function WaitJob { Get-Job | Wait-Job } <# Function to force the script to wait for jobs #>

Function vCenterUsersVM
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
		[string]$VMpass,
		[Parameter(Mandatory = $true)]
		[string]$LocalUser,
		[Parameter(Mandatory = $true)]
		[string]$LocalPass
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	$VM = Get-VM -Name $VMname
	$VMOS = ($VM).guest.OSFullName
	
	$LocalUserData = $LocalUser + ":" + $LocalPass
	
	if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, using password $VMpass, creating the user $LocalUserData" } <# If output is true #>
		
	if ($VMOS -like "*Linux*")
	{
		$Script = "useradd $LocalUser -p $LocalPass -s /bin/sh" <# Script #>
		
		. "$PSScriptRoot\vCenterCommandVM.ps1" <# Config file for command script #>
		vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -VMpass $VMpass -Output $Output -Script $Script | WaitJob
	}
	if ($VMOS -like "*Win*")
	{
		. "$PSScriptRoot\vCenterStoragePassword.ps1" <# Config file for Local admin group #>
		$LocalGroup = $VMdefualt.GroupLocalAdmin
		
		$Script1 = "NET USER $LocalUser $LocalPass /ADD" <# Script #>
		$Script2 = "Add-LocalGroupMember -Group $LocalGroup -Member $LocalUser" <# Script #>
		$Script3 = "whoami" <#  Do not remove this command, This command is here so windows will create the user folder #>
		$Scripts = $Script1, $Script2
		
		. "$PSScriptRoot\vCenterCommandVM.ps1" <# Config file for command script #>
		foreach ($Script in $Scripts) { vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -VMpass $VMpass -Output $Output -Force -Script $Script | WaitJob }
		vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -VMuser $LocalUser -VMpass $LocalPass -Output $Output -Force -Script $Script3 | WaitJob <# Send command as local user to create user folders #>
	}
}