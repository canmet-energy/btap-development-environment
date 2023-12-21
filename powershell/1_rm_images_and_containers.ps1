podman stop @(podman ps -a -q)
$command = 'podman system prune'
iex $command