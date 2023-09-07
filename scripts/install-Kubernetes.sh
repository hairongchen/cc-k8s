#!/bin/bash

###################################################
## ENV VARS required to run script
###################################################
#export env var
while read env_var; do
  export "$env_var"
done < /etc/environment

echo "########################################################"
echo "## Install Containerd, Runc and Kubernetes components ##"
echo "########################################################"


###################################################
## Setup proxy ENV
###################################################
export no_proxy=10.0.0.0/16,127.0.0.1,::1,10.96.0.0/12,10.244.0.0/16,localhost,10.0.0.0/8
export NO_PROXY=10.0.0.0/16,127.0.0.1,::1,10.96.0.0/12,10.244.0.0/16,localhost,10.0.0.0/8

###################################################
## Install general dependencies
###################################################
echo "install general dependencies"
apt-get update
apt-get install -y apt-transport-https ca-certificates curl

###################################################
## Install containerd and config
###################################################
echo "Install containerd"
mkdir -p /etc/containerd
cat <<EOF | tee /etc/containerd/config.toml
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    runtime_type = "io.containerd.runc.v2"
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
      SystemdCgroup = true
EOF

curl -fsSLo containerd-1.6.14-linux-amd64.tar.gz \
          https://github.com/containerd/containerd/releases/download/v1.6.14/containerd-1.6.14-linux-amd64.tar.gz
# install the binaries
tar Cxzvf /usr/local containerd-1.6.14-linux-amd64.tar.gz
rm containerd-1.6.14-linux-amd64.tar.gz

# config containerd systemd service
rm -f /etc/systemd/system/containerd.service
cat <<EOF | tee /etc/systemd/system/containerd.service
version = 2
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
#uncomment to enable the experimental sbservice (sandboxed) version of containerd/cri integration
#Environment="ENABLE_CRI_SANDBOXES=sandboxed"
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
Environment="HTTP_PROXY=http://child-prc.intel.com:913"
Environment="HTTPS_PROXY=http://child-prc.intel.com:913"
NO_PROXY="10.0.0.0/16,127.0.0.1,::1,10.96.0.0/12,10.244.0.0/16,localhos,10.0.0.0/8"

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF

cat /etc/systemd/system/containerd.service

systemctl daemon-reload
systemctl enable --now containerd

echo "########################################################"
echo "## Done install Containerd                            ##"
echo "########################################################"

###################################################
## Install runc
###################################################
echo "Install runc"
curl -fsSLo runc.amd64 \
          https://github.com/opencontainers/runc/releases/download/v1.1.3/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
rm runc.amd64

echo "########################################################"
echo "## Done install Runc                                  ##"
echo "########################################################"

###################################################
## Install CNI network plugins
###################################################
echo "Install CNI network plugins"
curl -fsSLo cni-plugins-linux-amd64-v1.1.1.tgz \
          https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz
rm cni-plugins-linux-amd64-v1.1.1.tgz

echo "########################################################"
echo "## Done install CNI binary                            ##"
echo "########################################################"

###################################################
## Setup kernel config for network
###################################################
echo "network traffic forwarding"
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe -a overlay br_netfilter

# sysctl params
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

###################################################
## Install kubeadm, kubelet kubectl
###################################################
echo "Install kubeadm, kubelet, kubectl"
# Add Kubernetes GPG key
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
          https://dl.k8s.io/apt/doc/apt-key.gpg
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# Add Kubernetes apt repo
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" \
          | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl

echo "########################################################"
echo "## Done install kubeadm, kubelet kubectl              ##"
echo "########################################################"