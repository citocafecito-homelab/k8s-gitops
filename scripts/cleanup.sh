sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock rmi --prune

sudo du -h --max-depth=1 /var/lib/containerd

df -h /mnt/*