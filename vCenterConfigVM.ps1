Function WaitJob { Get-Job | Wait-Job } <# Function to force the script to wait for jobs #>

Function vCenterConfigVM
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
		[string]$VMconfig,
		[Parameter(Mandatory = $true)]
		[string]$VMpass
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	
	. "$PSScriptRoot\vCenterVMtools.ps1"
	vCenterVMtools -Session $Session -VMSession $VMSession -VMname $VMname -Output $Output -Force | WaitJob <# Power on the VM if forced #>
	
	$VM = Get-VM -Name $VMname
	$VMOS = ($VM).guest.OSFullName
	If ([string]::IsNullOrEmpty($VMconfig)) { $VMconfig = [string]$VMOS } <# If you didnt use -VMconfig the script will use the machine OS to find the right config for it #>
	if ($Session) { $DisplaySession = ", Session: $Session" }
	if ($VMSession) { $DisplayVMSession = ", VMSession: $VMSession" }
	if ($VMname) { $DisplayVMname = ", VMname: $VMname" }
	if ($VMpass) { $DisplayVMpass = ", VMpass: $VMpass" }
	if ($VMconfig) { $DisplayVMconfig = ", VMconfig: $VMconfig" }
	
	. "$PSScriptRoot\vCenterCommandVM.ps1" <# Config file for command script #>
	. "$PSScriptRoot\vCenterStorageConfig.ps1" <# Run the config set from the StorageConfig list #>
	
	if ($Output -eq "True") { Write-Host "Running $FunctionName$DisplaySession$DisplayVMSession$DisplayVMname$DisplayVMpass$DisplayVMconfig" } <# If output is true #>
	
	if ($OSPassword -eq $true)
	{
		if ($Output -eq "True") { Write-Host "Running OSPassword for $VMname, Password: $VMpass" } <# If output is true #>
		. "$PSScriptRoot\vCenterStoragePassword.ps1" <# Config file for passwords #>
		if ($VMOS -like "*Win*")
		{
			$User = $VMdefualt.User <# Need to make the user as a single short string #>
			$Script = "NET USER $User $VMpass" <# Setting new password for the user via CMD, Powershell will fail with secure string issues.. #>
			vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -Output $Output -ScriptType "Bat" -Force -IgnoreErrors -Script $Script | WaitJob
		}
		if ($VMOS -like "*Linux*")
		{
			$NewAuth = $VMdefualt.User + ":" + $VMpass <# Grab the user and the password and output back as USER:PASS #>
			$Script = "sudo sh -c 'echo $NewAuth | chpasswd'" <# Change the user password #>
			vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -Output $Output -Force -IgnoreErrors -Script $Script | WaitJob
		}
	}
	if ($OSName -eq $true)
	{
		if ($Output -eq "True") { Write-Host "Running OSName for $VMname" } <# If output is true #>
		if ($VMOS -like "*Win*")
		{
			$Script = "Rename-Computer -NewName $VMname"
			vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -VMpass $VMpass -Output $Output -Force -Script $Script | WaitJob
		}
		if ($VMOS -like "*Linux*")
		{
			$Script = @"
sudo echo $VMname > /etc/hostname
sudo sed -i '2s/.*/127.0.0.1 $VMname/' /etc/hosts
hostnamectl set-hostname $VMname
sudo systemctl restart systemd-logind.service
sudo rm -f /etc/machine-id
sudo dbus-uuidgen --ensure=/etc/machine-id
sudo rm /var/lib/dbus/machine-id
dbus-uuidgen --ensure
sudo ip address flush scope global
sudo dhclient -v
"@ <# Update the hostname, restart network service #>
			vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -VMpass $VMpass -Output $Output -Force -Script $Script | WaitJob
		}
	}
	if ($OSPower -eq $true)
	{
		if ($Output -eq "True") { Write-Host "Running OSPower for $VMname" } <# If output is true #>
		if ($VMOS -like "*Win*")
		{
			$Script = @"
powercfg.exe -change disk-timeout-ac 0
powercfg.exe -change disk-timeout-dc 0
powercfg.exe -change monitor-timeout-ac 0
powercfg.exe -change monitor-timeout-dc 0
powercfg.exe -change standby-timeout-ac 0
powercfg.exe -change standby-timeout-dc 0
powercfg.exe -change hibernate-timeout-ac 0
powercfg.exe -change hibernate-timeout-dc 0
"@ <# Change the power setting to force the OS to never sleep #>
			vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -VMpass $VMpass -Output $Output -Force -Script $Script | WaitJob
		}
	}
	if ($OSRemote -eq $true)
	{
		if ($Output -eq "True") { Write-Host "Running OSRemote for $VMname" } <# If output is true #>
		if ($VMOS -like "*Linux*")
		{
			$Script = @"
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
"@ <# Command #>
			vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -VMpass $VMpass -Output $Output -Force -Script $Script | WaitJob
		}
	}	
}

<#	
	.NOTES
	===========================================================================
	Old commands:
	Move scripts to the machine
	$VM = Get-VM -Name $VMname -ErrorAction SilentlyContinue
	Get-Item "$PSScriptRoot\ScriptsWindows\*.*" | Copy-VMGuestFile -Destination "C:\Users\Administrator\OP" -VM $VM -LocalToGuest -GuestUser $VMdefualtuser -GuestPassword $VMdefualtpassword

	Commands:
	$Command1 = "-VMname "+$VMname
	$Script1 = '. "$env:SystemDrive\Users\Administrator\OP\WindowsChangeName.ps1"; ChangeName ' + $Command1
#>