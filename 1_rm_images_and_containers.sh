#!/bin/bash
podman rm $(podman ps -a -q) && podman rmi $(podman images -q)
