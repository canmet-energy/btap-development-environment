$os_version = "3.6.1"
$image = "canmet/btap-development-environment:$($os_version)"
$win_user = $env:UserName
$linux_home_folder = '/home/osdev'
Write-Host "Windows User:"  $win_user
Write-Host "image name:" $image
Write-Host "linux home folder:"  $linux_home_folder
	

	

