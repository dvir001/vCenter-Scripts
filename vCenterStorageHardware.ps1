if ($VMhardware -eq "Tiny")
{
	$HardwareConfig = @(
		@{
			CPU = "1"
			RAM = "1"
		})
}
if ($VMhardware -eq "Small")
{
	$HardwareConfig = @(
		@{
			CPU = "2"
			RAM = "2"
		})
}
if ($VMhardware -eq "Normal")
{
	$HardwareConfig = @(
		@{
			CPU = "2"
			RAM = "4"
		})
}
if ($VMhardware -eq "Large")
{
	$HardwareConfig = @(
		@{
			CPU = "4"
			RAM = "8"
		})
}