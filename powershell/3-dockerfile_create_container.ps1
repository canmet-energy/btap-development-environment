. .\env.ps1
$container_name =  $Args[0]
$command = docker
$arguments = "docker container create -it -v c:/Users/${win_user}:${linux_home_folder}/windows-host -v /run/desktop/mnt/host/wslg/.X11-unix:/tmp/.X11-unix -v /run/desktop/mnt/host/wslg:/mnt/wslg -e DISPLAY=:0 -e WAYLAND_DISPLAY=wayland-0 -e XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir -e PULSE_SERVER=/mnt/wslg/PulseServer --name ${container_name}  ${image}"
Write-Host $arguments
iex $arguments

	

