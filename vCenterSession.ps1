Function WaitJob { Get-Job | Wait-Job } <# Function to force the script to wait for jobs #>

Function vCenterSessionCheck
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $true)]
		[string]$SessionCheck
	)
	
	$DC = Get-Datacenter -Name * <# Get datastore #>
	
	for ($i=1; $i -le $SessionCheck; $i++) <# Check whether Session exists #>
	{
		$Session = $i
		$CurrentFolders = @()
		foreach ($Folder in (Get-Folder -Location $DC | Where-Object { $Session -contains $_.Name } | ForEach-Object{ $_.Name }))
		{
			$CurrentFolders += $Folder
		}
		if ($Currentfolders -contains $Session)
		{
			Write-Host "$Session exists"
		}
		else { }
	}
}

Function vCenterSessionFolder
{
	param (
		[Parameter(Mandatory = $false)]
		[string]$Output,
		[Parameter(Mandatory = $false)]
		[string]$Session,
		[Parameter(Mandatory = $false)]
		[string]$VMSession,
		[Parameter(Mandatory = $false)]
		[string]$StorageSession
	)
	
	$FunctionName = $MyInvocation.InvocationName
	
	if ($Session -and $VMSession)
	{
		if ($Output -eq "True") <# If output is true #>
		{
			Write-Host "Running $FunctionName for session $Session"
			$ErrorActionPreference = 'SilentlyContinue'
		}
		else { $ErrorActionPreference = 'SilentlyContinue' } <# Ignore on errors #>
		
		$DC = Get-Datacenter -Name * <# Get datastore #>
		if ([string]::IsNullOrEmpty($StorageSession)) { $StorageSession = 'Sessions' } <# The name for the main folder to store the sessions in case the string is empty #>
		
		$Folder1 = -join $DC, '\', $StorageSession <# Folders strings for main folder location #>
		$Folder2 = -join $DC, '\', $StorageSession, '\', $Session <# Folders strings for seesion mumber location #>
		$Folders = $Folder1, $Folder2 <# Combine folders strings #>
		
		Foreach ($Folder in $Folders)
		{
			$Path = $folder
			$SplitPath = $Path.split('\')
			
			$SplitPath = $SplitPath | Where-Object { $_ -ne $DC }
			Clear-Variable Folderpath
			Clear-Variable Parent
			
			Foreach ($directory in $SplitPath)
			{
				If ($Folderpath -ne $Null)
				{
					IF ($(Get-folder $directory | Where-Object Parentid -eq $($Folderpath.id)) -eq $Null)
					{
						Get-Folder -id $parent | New-Folder $directory
					}
					Else
					{
						$Folderpath = Get-Folder $directory | Where-Object Parentid -eq $($Folderpath.id)
						$Parent = $Folderpath.Id
					}
				}
				Else
				{
					$FolderExist = Get-folder -Name $directory
					IF ($FolderExist -eq $Null)
					{
						New-folder -Name $directory -Location VM
						$Folderpath = Get-folder $directory
					}
					Else
					{
						$Folderpath = Get-Folder $directory
						$Parent = $Folderpath.Id
					}
				}
			}
		}
	}
}

<#
foreach ($Folder in (Get-Folder -Location $DC | Where-Object { "vCenter-ThinkCyber", "datastore", "host", "vm", "1" -notcontains $_.Name } | ForEach-Object{ $_.Name }))
#>