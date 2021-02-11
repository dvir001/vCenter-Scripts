Function WaitJob { Get-Job | Wait-Job } <# Function to force the script to wait for jobs #>

Function vCenterPowerVM
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
		[Parameter(Mandatory = $false)]
		[string]$Power
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	if ($Power) { $DisplayPower = ", Running power command: $Power" }
	$ErrorActionPreference = 'SilentlyContinue' <# SilentlyContinue on errors #>
	
	$VMPower = (Get-VM -Name $VMname).PowerState <# Test if the VM online #>
	[bool]$VMPowerGuest = (Get-VM -Name $VMname).ExtensionData.guest.guestStateChangeSupported <# Test if the VM online #>
	
	if ($Power -like "*On*")
	{
		if ($VMpower -eq "PoweredOff") <# Test if the VM online #>
		{
			if ($Output -eq "True")
			{
				Write-Host "Running $FunctionName for $VMname$DisplayPower, current status: $VMpower, turning on"
				Start-VM -VM $VMname -Confirm:$false | WaitJob
			}
			else { Start-VM -VM $VMname -Confirm:$false | out-null | WaitJob }
		}
		else { if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname$DisplayPower, $VMname already running" } } <# If output is true #>
	}
	if ($Power -like "*Off*")
	{
		if ($VMPowerGuest -eq "True") <# Shuting down the VM #>
		{
			if ($Output -eq "True")
			{
				Write-Host "Running $FunctionName for $VMname$DisplayPower, current status: $VMPower, turning off"
				Stop-VM -kill $VMname -Confirm:$false | WaitJob
			}
			else { Stop-VM -kill $VMname -Confirm:$false | out-null | WaitJob }
		}
		else { if ($Output -eq "True") { Write-Output "Running $FunctionName for $VMname$DisplayPower, $VMname already off" } }
	}
	if (($Power -eq "Restart") -or ($Power -eq "Reset") -or ($Power -eq "Reboot"))
	{
		if ($VMPowerGuest -eq "True") <# Restart the VM #>
		{
			if ($Output -eq "True")
			{
				Write-Host "Running $FunctionName for $VMname$DisplayPower, current status: $VMPower, restarting"
				Restart-VMGuest -VM $VMname -Confirm:$false | WaitJob
				else { Restart-VMGuest -VM $VMname -Confirm:$false | WaitJob | out-null }
			}
			else
			{
				if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname$DisplayPower$DisplayPowerGuest, powering up $VMname" } <# If output is true #>
				Start-VM -VM $VMname -Confirm:$false | WaitJob
			}
		}
	}
	#else { if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname$DisplayPower, status: not found" } } <# If output is true #>
}
