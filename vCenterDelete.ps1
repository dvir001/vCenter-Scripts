Function WaitJob { Get-Job | Wait-Job } <# Function to force the script to wait for jobs #>

Function vCenterDeleteVM
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $false)]
		[string]$Session,
		[Parameter(Mandatory = $false)]
		[string]$VMSession,
		[Parameter(Mandatory = $false)]
		[string]$VMname
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	$VM = Get-VM -Name $VMname
	$VMOS = ($VM).guest.OSFullName
	
	if ($Output -eq "True")
	{
		Write-Host "Running $FunctionName for $VMname"  <# If output is true #>
		$ErrorActionPreference = 'SilentlyContinue' <# SilentlyContinue on errors #>
	}
	else { $ErrorActionPreference = 'SilentlyContinue' } <# SilentlyContinue on errors #>
	
	If ($VM) <# If the VM exist, delete it for a new VM #>
	{
		. "$PSScriptRoot\vCenterPowerVM.ps1"
		vCenterPowerVM -Session $Session -VMSession $VMSession -VMname $VMname -Power "Off" -Output $Output | WaitJob <# Power off the VM #>
		
		if ($Output -eq "True")  <# If output is true #>
		{
			Write-Host "Running $FunctionName, $VMname found, deleting $VMname for recreation"
			Remove-VM -VM $VMname -DeletePermanently -Confirm:$false | WaitJob <# Remove the VM #>
		}
		else { Remove-VM -VM $VMname -DeletePermanently -Confirm:$false | out-null | WaitJob } <# Remove the VM #>
	}
	else { if ($Output -eq "True") { Write-Host "Running $FunctionName, $VMname not found, nothing to delete, creating $VMname" }} <# If output is true #>
}

Function vCenterDeleteSession
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $false)]
		[string]$Session
	)
	
	if ($Output -eq "True") <# If output is true #>
	{
		$FunctionName = $MyInvocation.InvocationName
		Write-Host "Running $FunctionName for Session $Session"
		$ErrorActionPreference = 'SilentlyContinue'
	}
	else { $ErrorActionPreference = 'SilentlyContinue' } <# SilentlyContinue on errors #>
	
	$VMSessions = Get-Folder -Name $Session | Get-VM <# Get VM list from the session folder #>
	Foreach ($VMSession in $VMSessions) <# Run task for every VM under the folder #>
	{
		if ($Output -eq "True") { Write-Host "Running $FunctionName for Session $Session, stoping $($VMSession.name)" } <# If output is true #>
		. "$PSScriptRoot\vCenterPowerVM.ps1" <# Power scripts #>
		vCenterPowerVM -VMName $VMSession.name -Power "Off" -Output $Output | WaitJob <# Stop the VM #>
		if ($Output -eq "True")  <# If output is true #>
		{
			Write-Host "Running $FunctionName for Session $Session, removing $($VMSession.name)"
			Remove-VM -VM $VMSession.name -DeletePermanently -Confirm:$false | WaitJob
		}
		else { Remove-VM -VM $VMSession.name -DeletePermanently -Confirm:$false | out-null | WaitJob}
	}
	if ($Output -eq "True") { Remove-Folder -Folder $Session -Confirm:$false | WaitJob }
	else { Remove-Folder -Folder $Session -Confirm:$false | out-null | WaitJob }
}