# cc-k8s
POC for confidential Kubernetes cluster based on TDVM

# Basic design ideas
## cluster creation
1. Install required components to build Kubernetes base image
```
Containerd
Runc
CNI binaries
Kubernetes: kubeadm, kubelet kubectl
```

2. Create checksum/signature/encryption of base image as ground truth

3. Run Kubernetes masters with created image
```
call cluster join service for admission
cluster join service call attestation service for evidence attestation
admission criteria for masters: attested TDVM with trusted Kubernetes cluster components like containerd/runc/kubeadm/kubelet/cni binaries
```

4. Run Kubernetes worker nodes with created image and join Kubernetes Cluster with token
```
call cluster join service for admission
cluster join service call attestation service for evidence attestation
admission criteria for workers: attested TDVM with trusted Kubernetes cluster components like containerd/runc/kubeadm/kubelet/cni binaries
```

