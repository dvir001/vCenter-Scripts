if ($VMOS -like "*Linux*")
{
	$VMdefualt = @(
		@{
			User = "root"
			Pass = "1"
		})
}
if ($VMOS -like "*Win*")
{
	$VMdefualt = @(
		@{
			User		    = "Administrator"
			Pass		    = "1"
			GroupLocalAdmin = "Administrators"
		})
}

$Creds = @(
	@{
		User = $VMuser
		Pass = $VMpass
	},
	@{
		User = $VMdefualt.User
		Pass = $VMpass
	},
	@{
		User = "admin"
		Pass = $VMpass
	}
	@{
		User = "admin"
		pass = "pfsense"
	})

<#
	$Creds = @(
		@{
			User = $VMuser
		},
		@{
			User = "Administrator"
		}
	)
	foreach ($Cred in $Creds)
	{
		#Write-Host "Trying with $($Cred.User)"
		try
		{
			WaitJob
			$Command = Invoke-VMScript -VM $VMname -GuestUser $VMdefualtWindows.User -GuestPassword $VMpass -ScriptText $Script -ErrorAction Stop -ScriptType PowerShell
			$Command.ScriptOutput
			WaitJob
			break
		}
		catch [VMware.VimAutomation.ViCore.Types.V1.ErrorHandling.InvalidGuestLogin] {
			#Write-Host "Invalid credential $($Cred.User)"
		}
		catch
		{
			$out = "Other error for $($VMdefualtWindows.User)"
		}
#>