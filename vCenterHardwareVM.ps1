Function WaitJob { Get-Job | Wait-Job } <# Function to force the script to wait for jobs #>

Function vCenterHardwareVM
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
		[string]$VMhardware,
		[Parameter(Mandatory = $false)]
		[string]$VMCPU,
		[Parameter(Mandatory = $false)]
		[string]$VMRAM
	)
	
	if ($Session -and $VMSession) { $VMname = $Session + '-' + $VMSession }
	$FunctionName = $MyInvocation.InvocationName
	if ($Session) { $DisplaySession = ", Session: $Session" }
	if ($VMSession) { $DisplayVMSession = ", VMSession: $VMSession" }
	if ($VMname) { $DisplayVMname = ", VMname: $VMname" }
	if ($VMCPU) { $DisplayVMCPU = ", VMCPU: $VMCPU" }
	if ($VMRAM) { $DisplayVMRAM = ", VMRAM: $VMRAM" }
	if ($VMhardware) { $DisplayVMhardware = ", VMhardware: $VMhardware" }
	
	if ($Output -eq "True") { Write-Host "Running $FunctionName$DisplaySession$DisplayVMSession$DisplayVMname$DisplayVMCPU$DisplayVMRAM$DisplayVMhardware" } <# If output is true #>
		
	. "$PSScriptRoot\vCenterStorageHardware.ps1" <# Config file for Hardware #>
	
	if ([string]::IsNullOrEmpty($VMCPU)) <# Config the VM CPU by hardware #>
	{
		if ($Output -eq "True")
		{
			Write-Host "Running $FunctionName for $VMname, setting hardware as $VMhardware, CPU: $($HardwareConfig.CPU)" <# If output is true #>
			Set-VM -VM $VMname -NumCPU $HardwareConfig.CPU -Confirm:$false | WaitJob <# Set CPU for hardware setup #>
		}
		else { Set-VM -VM $VMname -NumCPU $HardwareConfig.CPU -Confirm:$false | out-null | WaitJob } <# Set CPU for hardware setup #>
	}
	else <# Config the VM CPU #>
	{
		if ($Output -eq "True")
		{
			Write-Host "Running $FunctionName for $VMname, setting hardware, CPU: $VMCPU" <# If output is true #>
			Set-VM -VM $VMname -NumCPU $VMCPU -Confirm:$false | WaitJob <# Set CPU if found CPU string #>
		}
		else { Set-VM -VM $VMname -NumCPU $VMCPU -Confirm:$false | out-null | WaitJob } <# Set CPU if found CPU string #>
	}
	
	if ([string]::IsNullOrEmpty($VMRAM)) <# Config the VM RAM by hardware #>
	{
		if ($Output -eq "True")
		{
			Write-Host "Running $FunctionName for $VMname, setting hardware as $VMhardware, RAM: $($HardwareConfig.RAM)" <# If output is true #>
			Set-VM -VM $VMname -MemoryGB $HardwareConfig.RAM -Confirm:$false | WaitJob <# Set RAM for hardware setup #>
		}
		else { Set-VM -VM $VMname -MemoryGB $HardwareConfig.RAM -Confirm:$false | out-null | WaitJob } <# Set RAM for hardware setup #>
	}
	else <# Config the VM RAM #>
	{
		if ($Output -eq "True")
		{
			Write-Host "Running $FunctionName for $VMname, setting hardware, RAM: $VMRAM" <# If output is true #>
			Set-VM -VM $VMname -MemoryGB $VMRAM -Confirm:$false | WaitJob <# Set CPU if found RAM string #>
		}
		else { Set-VM -VM $VMname -MemoryGB $VMRAM -Confirm:$false | out-null | WaitJob } <# Set CPU if found RAM string #>
	}
}