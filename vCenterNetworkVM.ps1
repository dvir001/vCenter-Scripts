Function WaitJob { Get-Job | Wait-Job } <# Function to force the script to wait for jobs #>

Function vCenterNetworkVM
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
		[string]$VMnetwork,
		[Parameter(Mandatory = $false)]
		[string]$MAC,
		[Parameter(Mandatory = $false)]
		[string]$VMnetworkType
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	if ($MAC) { $DisplayMAC = ", MacAddress: $MAC" }
	if ($VMnetworkType) { $DisplayVMnetworkType = ", VMnetworkType: $VMnetworkType" }
	If ($VMnetwork -eq "vmnetwork") { $VMnetwork = "VM Network" } <# Change "vmnetwork" to "VM Network" #>
	$ErrorActionPreference = 'SilentlyContinue' <# SilentlyContinue on errors #>
		
	if ($MAC -and $VMnetworkType) <# Use MAC and VMnetworkType settings if found #>
	{
		if ($Output -eq "True")
		{
			Write-Host "Running $FunctionName for $VMname, Network settings, Network: $VMnetwork, MacAddress: $MAC, VMnetworkType: $VMnetworkType"
			New-NetworkAdapter -VM $VMname -NetworkName $VMnetwork -MacAddress $MAC -Type $VMnetworkType -WakeOnLan:$true -StartConnected:$true -Confirm:$false | WaitJob
		}
		else { New-NetworkAdapter -VM $VMname -NetworkName $VMnetwork -MacAddress $MAC -Type $VMnetworkType -WakeOnLan:$true -StartConnected:$true -Confirm:$false | out-null | WaitJob }
	}
	if ($MAC -and [string]::IsNullOrEmpty($VMnetworkType)) <# Use MAC settings if found #>
	{
		if ($Output -eq "True")
		{
			Write-Host "Running $FunctionName for $VMname, Network settings, Network: $VMnetwork, MacAddress: $MAC"
			New-NetworkAdapter -VM $VMname -NetworkName $VMnetwork -MacAddress $MAC -WakeOnLan:$true -StartConnected:$true -Confirm:$false | WaitJob
		}
		else { New-NetworkAdapter -VM $VMname -NetworkName $VMnetwork -MacAddress $MAC -WakeOnLan:$true -StartConnected:$true -Confirm:$false | out-null | WaitJob }
	}
	if ($VMnetworkType -and [string]::IsNullOrEmpty($MAC)) <# Use VMnetworkType settings if found #>
	{
		if ($Output -eq "True")
		{
			Write-Host "Running $FunctionName for $VMname, Network settings, Network: $VMnetwork, VMnetworkType: $VMnetworkType"
			New-NetworkAdapter -VM $VMname -NetworkName $VMnetwork -Type $VMnetworkType -WakeOnLan:$true -StartConnected:$true -Confirm:$false | WaitJob
		}
		else { New-NetworkAdapter -VM $VMname -NetworkName $VMnetwork -Type $VMnetworkType -WakeOnLan:$true -StartConnected:$true -Confirm:$false | out-null | WaitJob }
	}
	else <# Run the command with the basic settings #>
	{
		if ($Output -eq "True")
		{
			Write-Host "Running $FunctionName for $VMname, Network settings, Network: $VMnetwork"
			New-NetworkAdapter -VM $VMname -NetworkName $VMnetwork -WakeOnLan:$true -StartConnected:$true -Confirm:$false | WaitJob
		}
		else { New-NetworkAdapter -VM $VMname -NetworkName $VMnetwork -WakeOnLan:$true -StartConnected:$true -Confirm:$false | out-null | WaitJob }
	}
}

Function vCenterDeleteNetworkVM
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
	
	$NIC = Get-NetworkAdapter -VM $VMname <# Grab VM NICs #>
	
	if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, Making sure $VMname is off before removing the NICs" } <# If output is true #>
	
	. "$PSScriptRoot\vCenterPowerVM.ps1"
	vCenterPowerVM -Session $Session -VMSession $VMSession -VMname $VMname -Power "Off" -Output $Output | WaitJob <# Turn the VM guest off #>
	
	if ($Output -eq "True") <# If output is true #>
	{
		Write-Host "Running $FunctionName, Removing all NICs from $VMname"
		$ErrorActionPreference = 'SilentlyContinue' <# SilentlyContinue on errors #>
		Remove-NetworkAdapter -NetworkAdapter $NIC -Confirm:$false | WaitJob <# Remove VM NICs #>
	}
	else
	{
		$ErrorActionPreference = 'SilentlyContinue' <# SilentlyContinue on errors #>
		Remove-NetworkAdapter -NetworkAdapter $NIC -Confirm:$false | out-null | WaitJob <# Remove VM NICs #>
	}
}