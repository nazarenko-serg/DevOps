#!/bin/bash

echo "1: Create configuration file for containerd:"
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

echo "2: Load modules:"
sudo modprobe overlay
sudo modprobe br_netfilter

echo "3: Set system configurations for Kubernetes networking:"
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

echo "4: Apply new settings"
sudo sysctl --system

echo "5: Install conteinerD"
sudo apt-get update && sudo apt-get install -y containerd

echo "6: Create default configuration file for containerd:"
sudo mkdir -p /etc/containerd

echo "7: Generate default containerd configuration and save to the newly "
sudo containerd config default | sudo tee /etc/containerd/config.toml

echo "8: Restart containerd to ensure new configuration file usage"
sudo systemctl restart containerd

echo "9: Verify that containerd is running:"
sudo systemctl status containerd

echo "10: disable swap"
sudo swapoff -a

echo "11: Install dependency packages"
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

echo "12: Download and add GPG key"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "13: Add Kubernetes to repository list"
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

echo "14: Update package listings"
sudo apt-get update

sudo apt-get install -y kubelet=1.24.0-00 kubeadm=1.24.0-00 kubectl=1.24.0-00

echo "15: Turn off automatic updates:"
sudo apt-mark hold kubelet kubeadm kubectl

echo "paste the kubeadm join command to join the cluster. Use sudo to run it as root:"
sudo kubeadm join <TOKEN FROM CONTROL PLANE>