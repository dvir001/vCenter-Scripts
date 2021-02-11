Function WaitJob { Get-Job | Wait-Job } <# Function to force the script to wait for jobs #>

Function vCenterInfoVM
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
		[string]$VMpass,
		[Parameter(Mandatory = $false)]
		[string]$VMuser,
		[Parameter(Mandatory = $false)]
		[string]$Info,
		[Parameter(Mandatory = $false)]
		[string]$OSInfo
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	$VM = Get-VM -Name $VMname
	$VMOS = ($VM).guest.OSFullName
	. "$PSScriptRoot\vCenterStoragePassword.ps1" <# Config file for Passwords #>
	
	$InfoIP = (Get-VM -Name $VMname).Guest.IPAddress | Where-Object { ([IPAddress]$_).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork }
	$InfoMAC = Get-VM -Name $VMname | Get-NetworkAdapter | Select-Object -ExpandProperty MacAddress
	$InfoName = (Get-VMGuest $VMname).HostName
	
	. "$PSScriptRoot\vCenterVMtools.ps1"
	vCenterVMtools -Session $Session -VMSession $VMSession -VMname $VMname -Output $Output -Force | WaitJob <# Power on the VM if forced #>
	
	if ($Info)
	{
		if ($Output -eq "True") <# If output is true #>
		{
			Write-Host "Running $FunctionName for $VMname, getting $Info info"
			$ErrorActionPreference = 'SilentlyContinue' <# SilentlyContinue on errors #>
			if ($Info -eq 'IP') { $InfoIP }
			if ($Info -eq 'MAC') { $InfoMAC }
			if ($Info -eq 'Name') { $InfoName }
		}
		else
		{
			$ErrorActionPreference = 'SilentlyContinue' <# SilentlyContinue on errors #>
			if ($Info -eq 'IP') { $InfoIP }
			if ($Info -eq 'MAC') { $InfoMAC }
			if ($Info -eq 'Name') { $InfoName }
		}
	}
	if ($OSInfo)
	{
		if ($VMOS -like "*Win*") { WindowsRunCommand -VMname $VMname -VMuser $VMuser -VMpass $VMpass -Info $Info -Output $Output | WaitJob }
		if ($VMOS -like "*Linux*") { LinuxRunCommand -VMname $VMname -VMuser $VMuser -VMpass $VMpass -Info $Info -Output $Output  | WaitJob }
	}
}

Function WindowsRunCommand
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $true)]
		[string]$VMname,
		[Parameter(Mandatory = $false)]
		[string]$VMuser,
		[Parameter(Mandatory = $true)]
		[string]$VMpass,
		[Parameter(Mandatory = $true)]
		[string]$Info
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	$VM = Get-VM -Name $VMname
	$VMOS = ($VM).guest.OSFullName
	. "$PSScriptRoot\vCenterStoragePassword.ps1" <# Config file for Passwords #>
	
	if ($Info -like "*IP*")
	{
		$Script = @'
	# Find the active IP
	$ipV4 = Test-Connection -ComputerName (hostname) -Count 1 | Select-Object IPV4Address

	# Show IP
	($ipV4 | ft -HideTableHeaders | Out-String).Trim()
'@
	}
	if ($Info -like "*MAC*")
	{
		$Script = @'
	# Find the computer name
	$CurrentComputerName = ($env:computername)
	
	# Find computer MAC
	$colItems = get-wmiobject -class "Win32_NetworkAdapterConfiguration" -computername $CurrentComputerName | Where-Object{ $_.IpEnabled -Match "True" }
	foreach ($objItem in $colItems)
	{
		$MAC = $objItem | Select-Object MACAddress
		($MAC | ft -HideTableHeaders | Out-String).Trim()
	}
'@
	}
	if ($Info -like "*Name*")
	{
		$Script = @'
	($env:computername)
'@
	}
	
	$Command = Invoke-VMScript -VM $VMname -GuestUser $VMdefualt.User -GuestPassword $VMpass -ScriptText $Script -ErrorAction Stop -ScriptType PowerShell | WaitJob
	
	if ($Output -eq "True") <# If output is true #>
	{
		Write-Host "Running $FunctionName for $VMname, getting $Info info, System: $VMOS"
		$Command.ScriptOutput
	}
	else { $Command.ScriptOutput | out-null }
}

Function LinuxRunCommand
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $true)]
		[string]$VMname,
		[Parameter(Mandatory = $false)]
		[string]$VMuser,
		[Parameter(Mandatory = $true)]
		[string]$VMpass,
		[Parameter(Mandatory = $true)]
		[string]$Info
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	$VM = Get-VM -Name $VMname
	$VMOS = ($VM).guest.OSFullName
	. "$PSScriptRoot\vCenterStoragePassword.ps1" <# Config file for Passwords #>
	
	if ($Info -like "*IP*")
	{
		$Script = @'
	hostname -I
'@ <# #ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' #>
	}
	if ($Info -like "*MAC*")
	{
		$Script = @'
	cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address
	}
'@
	}
	if ($Info -like "*Name*")
	{
		$Script = @'
	hostname
'@
	}
	
	$Command = Invoke-VMScript -VM $VMname -GuestUser $VMdefualt.User -GuestPassword $VMpass -ScriptText $Script -ErrorAction Stop -ScriptType Bash | WaitJob
	
	if ($Output -eq "True") <# If output is true #>
	{
		Write-Host "Running $FunctionName for $VMname, getting $Info info, System: $VMOS"
		$Command.ScriptOutput
	}
	else { $Command.ScriptOutput | out-null }
}