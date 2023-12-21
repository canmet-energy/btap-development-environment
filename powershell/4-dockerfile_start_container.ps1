. .\env.ps1
$container_name =  $Args[0]
podman start  -ia  $container_name