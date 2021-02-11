Function WaitJob { Get-Job | Wait-Job } <# Function to force the script to wait for jobs #>

Function vCenterUploadFileVM
{
	param (
		[switch]$Upload = $False,
		[switch]$Download = $False,
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
		[string]$VMuser,
		[Parameter(Mandatory = $false)]
		[string]$VMpass,
		[Parameter(Mandatory = $true)]
		[string]$File,
		[Parameter(Mandatory = $true)]
		[string]$DestinationFile
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	$VM = Get-VM -Name $VMname
	$VMOS = ($VM).guest.OSFullName
	$Q = '"'
	. "$PSScriptRoot\vCenterStoragePassword.ps1" <# Config file for passwords #>
	if ([string]::IsNullOrEmpty($VMuser)) { $VMuser = $VMdefualt.User } <# If user string is empty use default user, lines order need to be between two passwords files #>
	if ([string]::IsNullOrEmpty($VMpass)) { $VMpass = $VMdefualt.Pass } <# If password string is empty use default password, lines order need to be between two passwords files #>
	. "$PSScriptRoot\vCenterStoragePassword.ps1" <# Config file for passwords again, do not remove #>
	
	if ($Output -eq "True") { $ErrorActionPreference = 'Continue' } <# Continue on errors #>
	else { $ErrorActionPreference = 'SilentlyContinue' } <# SilentlyContinue on errors #>
	
	if ([bool]$Force -eq "True")
	{
		. "$PSScriptRoot\vCenterVMtools.ps1"
		vCenterVMtools -Session $Session -VMSession $VMSession -VMname $VMname -Output $Output -Force | WaitJob <# Power on the VM if forced #>
	}
	
	if (($Upload -eq $False) -and ($Download -eq $False)) { $Action = "LocalToGuest" } <# If -Upload is off and -Download is off, Local To Guest #>
	if (($Upload -eq $True) -and ($Download -eq $True)) { $Action = "LocalToGuest" } <# If -Upload is on and -Download is on, Local To Guest #>
	if (($Download -eq $True) -and ($Upload -ne $True)) { $Action = "GuestToLocal" } <# If -Download is on and -Upload is not on, Guest To Local #>
	if (($Upload -eq $True) -and ($Download -ne $True)) { $Action = "LocalToGuest" } <# If -Upload is on and -Download is not on, Local To Guest #>
	
	foreach ($Cred in $Creds) <# Login to the VM using the provided creds or the cred file, and send command #>
	{
		if ($Output -eq "True") { Write-Host "Running $FunctionName for $VMname, action: $Action, sending $Q$File$Q to $Q$DestinationFile$Q, running the script using creds, user: $($Cred.User), password: $($Cred.Pass)" } <# If output is true #>
		try
		{
			if ($Action -eq "LocalToGuest")
			{
				if ($Output -eq "True") { Copy-VMGuestFile -VM $VM -Source $File -Destination $DestinationFile -LocalToGuest -GuestUser $Cred.User -GuestPassword $Cred.Pass -Force | WaitJob } <# If output is true #>
				else { Copy-VMGuestFile -VM $VM -Source $File -Destination $DestinationFile -LocalToGuest -GuestUser $Cred.User -GuestPassword $Cred.Pass -Force | out-null | WaitJob }
			}
			if ($Action -eq "GuestToLocal")
			{
				if ($Output -eq "True") { Copy-VMGuestFile -VM $VM -Source $File -Destination $DestinationFile -GuestToLocal -GuestUser $Cred.User -GuestPassword $Cred.Pass -Force | WaitJob } <# If output is true #>
				else { Copy-VMGuestFile -VM $VM -Source $File -Destination $DestinationFile -GuestToLocal -GuestUser $Cred.User -GuestPassword $Cred.Pass -Force | out-null | WaitJob }
			}
			else {}
			break
		}
		catch [VMware.VimAutomation.ViCore.Types.V1.ErrorHandling.InvalidGuestLogin] { if ($Output -eq "True") { Write-Host "Invalid credential $($Cred.User)" } } <# If output is on #>
		catch { $out = "Other error for $($Cred.User)" }
	}
}