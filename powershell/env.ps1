$os_version = &git rev-parse --abbrev-ref HEAD 
$image = "canmet/btap-development-environment:$($os_version)"
$canmet_server_folder= "//s-bcc-nas2/Groups/Common\ Projects/HB/dockerhub_images/"
$xfolder = ""
if($xming -eq $null) {
if (Test-Path "c:\Program Files\Xming" ) {
   $xfolder = "c:\Program Files\Xming\Xming.exe"
}
if (Test-Path "c:\Program Files(x86)\Xming" ) {
   $xfolder = 'c:\Program Files(x86)\Xming\Xming.exe'
}
if (Test-Path "C:\Program Files\VcXsrv" ) {
   $xfolder = 'C:\Program Files\VcXsrv\vcxsrv.exe'
}

}
$host_ip = 'host.docker.internal'
$win_user = $env:UserName

$xming = Get-Process xming -ErrorAction SilentlyContinue
if($xming -eq $null) {
    $xmingexe = $xfolder
	$arguments = '-ac -multiwindow -clipboard  -dpi 108'
	Write-Host $xmingexe $arguments
	start-process $xmingexe $arguments
	}
	

$x_display = $host_ip + ':0.0'
$linux_home_folder = '/home/osdev'

Write-Host "Windows User:"  $win_user
Write-Host "host_ip:" $host_ip
Write-Host "X server IP:" $x_display
Write-Host "image name:" $image
Write-Host "linux home folder:"  $linux_home_folder
	

	

