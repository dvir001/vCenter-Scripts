if ($VMconfig -like "*Windows Server 2016*")
{
	$OSPassword = $true
	$OSName = $true
	$OSPower = $true
}

if ($VMconfig -like "*Windows 10*")
{
	$OSPassword = $true
	$OSName = $true
	$OSPower = $true
}

if ($VMconfig -like "*Ubuntu*")
{
	$OSPassword = $true
	$OSName = $true
	$OSRemote = $true
}

if ($VMconfig -like "*Debian GNU*")
{
	$OSPassword = $true
	$OSName = $true
	$OSRemote = $true
}