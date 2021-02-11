Function WaitJob { Get-Job | Wait-Job } <# Function to force the script to wait for jobs #>

Function vCenterCreateVM
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $true)]
		[string]$ESXI,
		[Parameter(Mandatory = $true)]
		[string]$StorageName,
		[Parameter(Mandatory = $true)]
		[string]$TemplateName,
		[Parameter(Mandatory = $false)]
		[string]$Session,
		[Parameter(Mandatory = $false)]
		[string]$VMSession,
		[Parameter(Mandatory = $false)]
		[string]$VMname,
		[Parameter(Mandatory = $true)]
		[string]$VMhardware,
		[Parameter(Mandatory = $false)]
		[string]$VMCPU,
		[Parameter(Mandatory = $false)]
		[string]$VMRAM,
		[Parameter(Mandatory = $true)]
		[string]$VMnetwork,
		[Parameter(Mandatory = $false)]
		[string]$MAC,
		[Parameter(Mandatory = $false)]
		[string]$VMnetworkType
	)
	
	if (-not [string]::IsNullOrEmpty($Session) -and -not [string]::IsNullOrEmpty($VMSession)) { $VMname = $Session + '-' + $VMSession }
	if (-not [string]::IsNullOrEmpty($Session)) { $DisplaySession = ", Session: $Session" }
	if (-not [string]::IsNullOrEmpty($VMSession)) { $DisplayVMSession = ", VMSession: $VMSession" }
	if (-not [string]::IsNullOrEmpty($VMname)) { $DisplayVMname = ", VMname: $VMname" }
	if (-not [string]::IsNullOrEmpty($VMCPU)) { $DisplayVMCPU = ", VMCPU: $VMCPU" }
	if (-not [string]::IsNullOrEmpty($VMRAM)) { $DisplayVMRAM = ", VMRAM: $VMRAM" }
	if (-not [string]::IsNullOrEmpty($VMhardware)) { $DisplayVMhardware = ", VMhardware: $VMhardware" }
	$FunctionName = $MyInvocation.InvocationName
	
	if ($Output -eq "True") { Write-Host "Running $FunctionName, Creating the VM, ESXI: $ESXI, StorageName: $StorageName, TemplateName: $TemplateName, VMnetwork: $VMnetwork$DisplaySession$DisplayVMSession$DisplayVMname$DisplayVMCPU$DisplayVMRAM$DisplayVMhardware" } <# Display info list If Output is true #>
	
	vCenterCreateVMFromTemplate -ESXI $ESXI -StorageName $StorageName -Session $Session -VMSession $VMSession -VMname $VMname -TemplateName $TemplateName -Output $Output | WaitJob <# Create VM from template #>
	
	. "$PSScriptRoot\vCenterHardwareVM.ps1" <# Config VM settings #>
	vCenterHardwareVM -Session $Session -VMSession $VMSession -VMname $VMname -VMhardware $VMhardware -VMCPU $VMCPU -VMRAM $VMRAM -Output $Output | WaitJob
	
	. "$PSScriptRoot\vCenterNetworkVM.ps1" <# Remove VM network cards #>
	vCenterDeleteNetworkVM -Session $Session -VMSession $VMSession -VMname $VMname -Output $Output | WaitJob
	
	. "$PSScriptRoot\vCenterNetworkVM.ps1" <# Config VM network #>
	vCenterNetworkVM -Session $Session -VMSession $VMSession -VMname $VMname -VMnetwork $VMnetwork -MAC $MAC -VMnetworkType $VMnetworkType -Output $Output | WaitJob
}

Function vCenterCreateVMFromTemplate
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $true)]
		[string]$ESXI,
		[Parameter(Mandatory = $true)]
		[string]$StorageName,
		[Parameter(Mandatory = $false)]
		[string]$Session,
		[Parameter(Mandatory = $false)]
		[string]$VMSession,
		[Parameter(Mandatory = $false)]
		[string]$VMname,
		[Parameter(Mandatory = $true)]
		[string]$TemplateName
	)
	
	if (-not [string]::IsNullOrEmpty($Session) -and -not [string]::IsNullOrEmpty($VMSession)) { $VMname = $Session + '-' + $VMSession }
	$DS = Get-Datastore -Name $StorageName <# VM long Strings #>
	$ESX = Get-VMHost -Name $ESXI <# VM long Strings #>
	$Template = Get-Template -Name $TemplateName <# VM long Strings #>
	if (-not [string]::IsNullOrEmpty($Session)) { $DisplaySession = ", Session: $Session" }
	if (-not [string]::IsNullOrEmpty($VMSession)) { $DisplayVMSession = ", VMSession: $VMSession" }
	if (-not [string]::IsNullOrEmpty($VMname)) { $DisplayVMname = ", VMname: $VMname" }
	$ErrorActionPreference = 'Stop' <# Stop on errors #>
	$FunctionName = $MyInvocation.InvocationName
	
	if ($Output -eq "True") <# If output is true #>
	{
		Write-Host "Running $FunctionName, ESXI: $ESXI, StorageName: $StorageName$DisplaySession$DisplayVMSession$DisplayVMname, TemplateName: $TemplateName"
		New-VM -Name $VMname -Template $Template -ResourcePool $ESX -Datastore $StorageName -Location $Session -DiskStorageFormat Thin | WaitJob <# Create VM #>
	}
	else { New-VM -Name $VMname -Template $Template -ResourcePool $ESX -Datastore $StorageName -Location $Session -DiskStorageFormat Thin | out-null | WaitJob } <# Create VM #>
}