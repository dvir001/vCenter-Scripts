Function WaitJob { Get-Job | Wait-Job }

function vCenterLogin
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $true)]
		[string]$vCenter,
		[Parameter(Mandatory = $true)]
		[string]$vCenterUser,
		[Parameter(Mandatory = $true)]
		[string]$vCenterPass
	)
	
	$FunctionName = $MyInvocation.InvocationName
	
	if ($Output -eq "True") { Write-Host "Running $FunctionName" } <# If output is true #>
	else { $ErrorActionPreference = 'Ignore' } <# Ignore on errors #>
	
    if ($null -eq (Get-Module -Name 'VMware.PowerCLI')) <# Import the VMware PowerCLI module #>
	{
		VMwarePowerCLI -Output $Output <# Look for VMware.PowerCLI and install if missing #>
		if ($Output -eq "True") { Set-PowerCLIConfiguration -Scope User -ParticipateInCeip $false -InvalidCertificateAction Ignore -Confirm:$false | out-null } <# Disable CEIP and ignore certificate warnings #>
		else { Set-PowerCLIConfiguration -Scope User -ParticipateInCeip $false -InvalidCertificateAction Ignore -Confirm:$false | out-null } <# Disable CEIP and ignore certificate warnings #>
    }

    if ($Global:DefaultVIServers.Count -gt 0) { $global:DefaultVIServers[0] } <# Return current connection #>
    else
	{
		if ($Output -eq "True") <# If output is true #>
		{
			Write-Host "Running $FunctionName, Connect-VIServer, Server: $vCenter, User: $vCenterUser, Password: $vCenterPass"
			Connect-VIServer -Server $vCenter -User $vCenterUser -Password $vCenterPass <# Connect to the VMware vCenter #>
		}
		else { Connect-VIServer -Server $vCenter -User $vCenterUser -Password $vCenterPass | out-null } <# Connect to the VMware vCenter #>
	}
}

function VMwarePowerCLI
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output
	)
	
	if ($Output -eq "True") <# If output is true #>
	{
		$ScriptName = (split-path $MyInvocation.PSCommandPath -Leaf) -replace '.ps1', ''
		$FunctionName = $MyInvocation.InvocationName
		Write-Host "Running $ScriptName, $FunctionName check"
	}
	else { $ErrorActionPreference = 'Ignore' } <# Ignore on errors #>
	
	if (Get-Module -ListAvailable -Name VMware.PowerCLI) <# If the module isnt installed, then install it #>
	{
		if ($Output -eq "True") { Write-Host "Running $ScriptName, $FunctionName installed" } <# If output is true #>
	}
	else
	{
		if ($Output -eq "True") <# If output is true #>
		{
			Write-Host "Running $ScriptName, $FunctionName Not installed, Installing..."
			Install-Module VMware.PowerCLI -AllowClobber -Force -Confirm:$false | WaitJob
		}
		else { Install-Module VMware.PowerCLI -AllowClobber -Force -Confirm:$false | out-null | WaitJob }
	}
	try { Import-Module -Name 'VMware.PowerCLI' -Verbose:$false *>$null } <# Import VMware.PowerCLI #>
	catch { }
}