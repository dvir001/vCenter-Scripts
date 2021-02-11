Function WaitJob { Get-Job | Wait-Job } <# Function to force the script to wait for jobs #>

Function vCenterVMtools
{
	param (
		[switch]$Force = $False,
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $false)]
		[string]$Session,
		[Parameter(Mandatory = $false)]
		[string]$VMSession,
		[Parameter(Mandatory = $false)]
		[string]$VMname,
		[Parameter(Mandatory = $false)]
		[string]$Max,
		[Parameter(Mandatory = $false)]
		[string]$Wait
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	if ($VMWait) { $DisplayWait = ", Wait: Wait" }
	if ($VMMax) { $DisplayMax = ", Max: Max" }
	
	if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname" } <# If output is true #>
	
	$Stoploop = $false
	$WaitTask = $false
	[int]$Retrycount = "0"
	if ([string]::IsNullOrEmpty($Max)) { $Max = "15" }
	[int]$RetrycountMax = $Max
	
	if ([bool]$Force -eq "True")
	{
		. "$PSScriptRoot\vCenterPowerVM.ps1"
		vCenterPowerVM -Session $Session -VMSession $VMSession -VMname $VMname -Power "On" -Output $Output | WaitJob <# Power on the VM if forced #>
	}
	
	do <# Wait for VMtools to start, loop #>
	{
		$ErrorActionPreference = 'SilentlyContinue' <# SilentlyContinue on errors #>
		$VMtoolsTrue = "True"
		[bool]$VMtools = (Get-VM -Name $VMname).ExtensionData.guest.guestOperationsReady
		if ($VMtools -eq $VMtoolsTrue)
		{
			if ([string]::IsNullOrEmpty($Wait)) { $Wait = "30" } <# Sleep time #>
			if ($WaitTask -eq $true)
			{
				if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, VMtools status: $VMtools, Start sleep: $Wait, making sure $VMname is ready for config" } <# If output is on #>
				Start-Sleep -Seconds $Wait <# Start sleep #>
			}
			if ($WaitTask -eq $false) { if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, VMtools status: $VMtools" }} <# If output is on #>
			Wait-Tools -VM $VMname -TimeoutSeconds 10 | out-null
			$Stoploop = $true
		}
		if ($VMtools -ne $VMtoolsTrue) <# Start sleep if VMtools isnt ready #>
		{
			if ([string]::IsNullOrEmpty($VMtools)) { $VMtools = "FAILED"}
			$Retrycount = $Retrycount + 1
			$WaitTask = $true
			if ($Retrycount -gt $RetrycountMax)
			{
				if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, VMtools status: $VMtools, after $RetrycountMax requests, stoping loop" } <# If output is on #>
				$Stoploop = $true
			}
			else
			{
				$Sleep = "5" <# Sleep time #>
				if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, VMtools status: $VMtools, start sleep: $Sleep" } <# If output is true #>
				Start-Sleep -Seconds $Sleep
			}
		}
	}
	While ($Stoploop -eq $false)	
}

Function vCenterVMtoolsPower
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
		[string]$Max,
		[Parameter(Mandatory = $false)]
		[string]$Wait
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	
	if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname" } <# If output is true #>
	
	$Stoploop = $false
	$WaitTask = $false
	[int]$Retrycount = "0"
	if ([string]::IsNullOrEmpty($Max)) { $Max = "15" }
	[int]$RetrycountMax = $Max
	
	do <# Wait for VMtools to start, loop #>
	{
		$ErrorActionPreference = 'SilentlyContinue' <# SilentlyContinue on errors #>
		$VMtoolsTrue = "True"
		[bool]$VMtools = (Get-VM -Name $VMname).ExtensionData.guest.guestStateChangeSupported
		if ($VMtools -eq $VMtoolsTrue)
		{
			if ([string]::IsNullOrEmpty($Wait)) { $Wait = "30" } <# Sleep time #>
			if ($WaitTask -eq $true)
			{
				if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, VMtools status: $VMtools, Start sleep: $Wait, making sure $VMname is ready for config" } <# If output is on #>
				Start-Sleep -Seconds $Wait <# Start sleep #>
			}
			if ($WaitTask -eq $false) { if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, VMtools status: $VMtools" } } <# If output is on #>
			Wait-Tools -VM $VMname -TimeoutSeconds 10 | out-null
			$Stoploop = $true
		}
		if ($VMtools -ne $VMtoolsTrue) <# Start sleep if VMtools isnt ready #>
		{
			if ([string]::IsNullOrEmpty($VMtools)) { $VMtools = "FAILED" }
			$Retrycount = $Retrycount + 1
			$WaitTask = $true
			if ($Retrycount -gt $RetrycountMax)
			{
				if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, VMtools status: $VMtools, after $RetrycountMax requests, stoping loop" } <# If output is on #>
				$Stoploop = $true
			}
			else
			{
				$Sleep = "5" <# Sleep time #>
				if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, VMtools status: $VMtools, start sleep: $Sleep" } <# If output is true #>
				Start-Sleep -Seconds $Sleep
			}
		}
	}
	While ($Stoploop -eq $false)
}

<#$VMtoolsTrue = "guestToolsRunning"
$VMtools = (Get-VM -Name $VMname).ExtensionData.Guest.toolsRunningStatus#>

<#
. "$PSScriptRoot\vCenterVMtools.ps1"
vCenterVMtools -VMname $VMname
#>