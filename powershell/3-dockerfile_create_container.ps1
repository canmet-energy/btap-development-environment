. .\env.ps1
$container_name =  $Args[0]
$command = podman
$arguments = "podman create -ti -e DISPLAY=${x_display} -P -v c:/Users/${win_user}:${linux_home_folder}/windows-host --name ${container_name}  ${image}"
Write-Host $arguments
iex $arguments

	

