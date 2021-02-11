param (
	[Parameter(Mandatory = $false)]
	[string]$Output,
	[switch]$help = $false
)
if ($help)
{
	$Quotes = '"'
	$Example_Output = "'True'"
	$Example_vCenter = "'192.168.57.240'"
	$Example_vCenterUser = "'Administrator@vCenter.local'"
	$Example_vCenterPass = "'PA$$WORD'"
	write-host "`nvCenter Usage:"
	write-host "  vCenter                       [-help]"
	write-host "`nParameters:"
	write-host "   -help                           : display this help"
	write-host "`nExamples:"
	write-host "   vCenter -help"
	write-host '   powershell -command "& { . C:\vCenter\vCenter.ps1 -help }"'
	write-host "   [Simply add -help to vCenter to get this help page]"
	write-host "`nvCenterLogin Usage:"
	write-host "                                [-vCenter <vCenterIP>] [-vCenterUser <AdminUser>] [-vCenterPass <AdminPass>]"
	write-host "                                [-Output <OutputMod>]"
	write-host "`nParameters:"
	write-host "   -vCenter <vCenterIP>            : The vCenter IP to login to"
	write-host "   -vCenterUser <AdminUser>        : Administrator user to be used with the script"
	write-host "   -vCenterPass <AdminPass>        : Administrator password to be used with the script"
	write-host "   -Output <OutputMod>             : Use with string $Example_Output to get full output data"
	write-host "`nExamples:"
	write-host "   vCenterLogin -vCenter $Example_vCenter -vCenterUser 'Administrator@vCenter.local' -vCenterPass 'PA$$WORD'"
	write-host "   powershell -command $Quotes& { . C:\vCenter\vCenter.ps1 ; vCenterLogin -vCenter $Example_vCenter -vCenterUser $Example_vCenterUser -vCenterPass $Example_vCenterPass$Quotes -Output $Example_Output"
	write-host "   [Use this command before any other task to connect to the vCenter]"
	write-host "`nvCenterCreateVM Usage:"
	write-host "                                [-ESXI <ESXIIP>] [-StorageName <DataPoolStorage>]"
	write-host "                                [-Session <SessionNum>] [-VMSession <SessionVMname>] [-VMname <VMname>]"
	write-host "                                [-Session <SessionNum>] [-VMSession <SessionVMname>] [-VMname <VMname>] [-VMpass <OSNewPass>]"
	write-host "                                [-Output <OutputMod>]"
	write-host "`nParameters:"
	write-host "   -vCenter <vCenterIP>            : The vCenter IP to login to"
	write-host "   -vCenterUser <AdminUser>        : Administrator user to be used with the script"
	write-host "   -vCenterPass <AdminPass>        : Administrator password to be used with the script"
	write-host "   -Output <OutputMod>             : Use with string $Example_Output to get full output data"
	write-host "`nExamples:"
	write-host "   vCenterLogin -vCenter $Example_vCenter -vCenterUser 'Administrator@vCenter.local' -vCenterPass 'pass'"
	write-host "   powershell -command $Quotes& { . C:\vCenter\vCenter.ps1 ; vCenterLogin -vCenter $Example_vCenter -vCenterUser $Example_vCenterUser -vCenterPass $Example_vCenterPass$Quotes -Output $Example_Output"
	write-host "   [Use this command before any other task to connect to the vCenter]"
    $ErrorActionPreference = 'SilentlyContinue' <# SilentlyContinue on errors #>
	exit
}
else { if ($Output -eq "True") { Write-Host "(Call with -help for instructions)" }} <# If output is true #>

Function WaitJob { Get-Job | Wait-Job }

Function vCenterLogin
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $true)]
		[string]$vCenter,
		[Parameter(Mandatory = $true)]
		[string]$vCenterUser,
		[Parameter(Mandatory = $false)]
		[string]$vCenterPass
	)

	. "$PSScriptRoot\vCenterLogin.ps1" <# Connect to the vCenter task set #>
	vCenterLogin -vCenter $vCenter -vCenterUser $vCenterUser -vCenterPass $vCenterPass -Output $Output
}

Function vCenterCreateVM
{
	param (
		[switch]$SessionFolder = $false,
		[switch]$DeleteVM = $false,
		[switch]$CreateVM = $false,
		[switch]$ConfigVM = $false,
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $true)]
		[string]$ESXI,
		[Parameter(Mandatory = $true)]
		[string]$StorageName,
		[Parameter(Mandatory = $false)]
		[string]$StorageSession,
		[Parameter(Mandatory = $false)]
		[string]$Session,
		[Parameter(Mandatory = $false)]
		[string]$VMSession,
		[Parameter(Mandatory = $false)]
		[string]$VMname,
		[Parameter(Mandatory = $true)]
		[string]$VMpass,
		[Parameter(Mandatory = $true)]
		[string]$VMnetwork,
		[Parameter(Mandatory = $true)]
		[string]$TemplateName,
		[Parameter(Mandatory = $false)]
		[string]$VMconfig,
		[Parameter(Mandatory = $false)]
		[string]$VMCPU,
		[Parameter(Mandatory = $false)]
		[string]$VMRAM,
		[Parameter(Mandatory = $false)]
		[string]$VMhardware
	)
	
	if ($SessionFolder -eq $false)
	{
		vCenterSessionFolder -StorageSession $StorageSession -Session $Session -VMSession $VMSession -Output $Output <# Create VM session #>
	}
	
	if ($DeleteVM -eq $false)
	{
		vCenterDeleteVM -Session $Session -VMSession $VMSession -VMname $VMname -Output $Output <# Delete VM function set #>
	}
	
	if ($CreateVM -eq $false)
	{
		. "$PSScriptRoot\vCenterCreateVM.ps1" <# Create VM function set #>
		vCenterCreateVM -ESXI $ESXI -StorageName $StorageName -TemplateName $TemplateName -VMnetwork $VMnetwork -Session $Session -VMSession $VMSession -VMname $VMname -VMCPU $VMCPU -VMRAM $VMRAM -VMhardware $VMhardware -Output $Output
	}
	
	if ($ConfigVM -eq $false)
	{
		. "$PSScriptRoot\vCenterConfigVM.ps1" <# Config VM function set #>
		vCenterConfigVM -Session $Session -VMSession $VMSession -VMname $VMname -VMconfig $VMconfig -VMpass $VMpass -Output $Output
	}
	
	
}

Function vCenterSessionCheck
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $true)]
		[string]$SessionCheck
	)
	
	. "$PSScriptRoot\vCenterSession.ps1" <#  #>
	vCenterSessionCheck -SessionCheck $SessionCheck -Output $Output
}

Function vCenterSessionFolder
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $false)]
		[string]$StorageSession,
		[Parameter(Mandatory = $false)]
		[string]$Session,
		[Parameter(Mandatory = $false)]
		[string]$VMSession
	)
	
	. "$PSScriptRoot\vCenterSession.ps1" <#  #>
	vCenterSessionFolder -StorageSession $StorageSession -Session $Session -VMSession $VMSession -Output $Output
}

Function vCenterDeleteSession
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $false)]
		[string]$Session
	)
	
	. "$PSScriptRoot\vCenterDelete.ps1" <# Send VM guest command #>
	vCenterDeleteSession -Session $Session -Output $Output
}

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

	. "$PSScriptRoot\vCenterDelete.ps1" <# Send VM guest command #>
	vCenterDeleteVM -Session $Session -VMSession $VMSession -VMname $VMname -Output $Output
}

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
	
	. "$PSScriptRoot\vCenterNetworkVM.ps1" <#  #>
	vCenterNetworkVM -Session $Session -VMSession $VMSession -VMname $VMname -VMnetwork $VMnetwork -MAC $MAC -VMnetworkType $VMnetworkType -Output $Output
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
	
	. "$PSScriptRoot\vCenterNetworkVM.ps1" <#  #>
	vCenterDeleteNetworkVM -Session $Session -VMSession $VMSession -VMname $VMname -Output $Output
}

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
	
	. "$PSScriptRoot\vCenterInfoVM.ps1" <# Get VM Info #>
	vCenterInfoVM -Session $Session -VMSession $VMSession -VMname $VMname -VMuser $VMuser -VMpass $VMpass -Info $Info -OSInfo $OSInfo -Output $Output
}

Function vCenterUsersVM
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
		[string]$VMpass,
		[Parameter(Mandatory = $true)]
		[string]$LocalUser,
		[Parameter(Mandatory = $true)]
		[string]$LocalPass
	)
	
	. "$PSScriptRoot\vCenterUsersVM.ps1" <# Get VM Info #>
	vCenterUsersVM -Session $Session -VMSession $VMSession -VMname $VMname -VMpass $VMpass -LocalUser $LocalUser -LocalPass $LocalPass -Output $Output
}

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
		
	. "$PSScriptRoot\vCenterPowerVM.ps1" <# Send VM power command #>
	vCenterPowerVM -Session $Session -VMSession $VMSession -VMname $VMname -Power $Power -Output $Output
}

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
	
	. "$PSScriptRoot\vCenterVMtools.ps1" <#  #>
	if ([bool]$Force -eq "true") { vCenterVMtools -Session $Session -VMSession $VMSession -VMname $VMname -Max $Max -Wait $Wait -Output $Output -Force }
	else { vCenterVMtools -Session $Session -VMSession $VMSession -VMname $VMname -Max $Max -Wait $Wait -Output $Output }
}

Function vCenterCommandVM
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
		[string]$VMuser,
		[Parameter(Mandatory = $true)]
		[string]$VMpass,
		[Parameter(Mandatory = $false)]
		[string]$ScriptType,
		[Parameter(Mandatory = $true)]
		[string]$Script
	)
	
	. "$PSScriptRoot\vCenterCommandVM.ps1" <# Send VM guest command #>
	if ([bool]$Force -eq "true") { vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -VMuser $VMuser -VMpass $VMpass -ScriptType $ScriptType -Script $Script -Output $Output -Force }
	else { vCenterCommandVM -Session $Session -VMSession $VMSession -VMname $VMname -VMuser $VMuser -VMpass $VMpass -ScriptType $ScriptType -Script $Script -Output $Output }
}

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
	
	. "$PSScriptRoot\vCenterUploadFileVM.ps1" <# Upload file to VM #>
	$ActionUpload = $False
	$ActionDownload = $False
	$ActionForce = $False
	if ([bool]$Upload -eq "True") { $ActionUpload = $True }
	if ([bool]$Download -eq "True") { $ActionDownload = $True }
	if ([bool]$Force -eq "True") { $ActionForce = $True }
	vCenterUploadFileVM -Session $Session -VMSession $VMSession -VMname $VMname -VMuser $VMuser -VMpass $VMpass -File $File -DestinationFile $DestinationFile -Output $Output -Upload:$ActionUpload -Download:$ActionDownload -Force:$ActionForce
}