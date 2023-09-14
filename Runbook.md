
# Steps

## 1. Build TDVM image with Kubernetes basisc components installed
```
wget https://raw.githubusercontent.com/hairongchen/cc-k8s/main/scripts/install-Kubernetes.sh
sudo ./create-ubuntu-image.sh -f -r /srv/mvp-tdx-2023ww32-5 -x ./install-Kubernetes.sh -o cc-node.qcow2
```

## 2. Define Kubernetes master and worker nodes
Define the TDVM via tepmplate from [tdx-tools](https://intel.github.io/confidential-cloud-native-primitives/)

## 3. Start master TDVM node
Start the TDVM via virsh:
```
sudo virsh define ccnp-k8s-master.xml
sudo virsh start ccnp-k8s-master
```

Config the TDVM as master node:
>Tips: update system proxy and no_proxy at /etc/environment if necessary
```
hostname tdx-master
echo tdx-master > /etc/hostname
```

Initialize the Kubernetes master node and control plane
```
kubeadm init --pod-network-cidr=10.244.0.0/16
```
When the installation finishes, save the join command to worker node to join the cluster with:
```
kubeadm join 10.1.125.100:6443 --token i31w9b.j2penu8x3dnbfbjs \
        --discovery-token-ca-cert-hash sha256:82ebde2f9ed76fb71738a7dbc56479c04f376e4ee2095a46a8584dff028d9434
```

Post initialization setup for kubeconfig:
```
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

Install flannel CNI:
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

Check if the master node is ready and the system PODs status are OK
```
kubectl get node
kubectl get pod -A
```

## 4. Start worker TDVM node
Start the TDVM via virsh:
```
sudo virsh define ccnp-k8s-node1.xml
sudo virsh start ccnp-k8s-node1
```

Config the TDVM as master node:
>Tips: update system proxy and no_proxy at /etc/environment if necessary
```
hostname tdx-node1
echo tdx-node1 > /etc/hostname
```

Join the cluster via previously saved command:
```
kubeadm join 10.1.125.100:6443 --token i31w9b.j2penu8x3dnbfbjs \
        --discovery-token-ca-cert-hash sha256:82ebde2f9ed76fb71738a7dbc56479c04f376e4ee2095a46a8584dff028d9434
```

Check if the worker node is ready and the system PODs status are OK
```
kubectl get node
kubectl get pod -A
```

Repeat above steps to add more worker nodes.


## 5. Deploy workload
```
kubectl apply -f deployment/nginx-deployment.yaml
kubectl get pod
```