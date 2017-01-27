# kubeadm-experiment

An experiment installing k8s on a 2 node cluster using [kubeadm](https://kubernetes.io/docs/getting-started-guides/kubeadm/)

## install

requirements:

 * [virtualbox](https://www.virtualbox.org/wiki/Downloads)
 * [vagrant](https://www.vagrantup.com/downloads.html)

It's useful to have the virtualbox guest additions plugin:

```bash
$ vagrant plugin install vagrant-vbguest
```

## initial setup

The `Vagrantfile` describes 2 x 2GB debian/jessie machines

```bash
$ vagrant up
```

You will see this message after the first startup:

```bash
GRUB updated - restart both VMS
```
So we need to:

```bash
$ vagrant halt
$ vagrant up
```

## connect

To SSH onto the nodes:

```bash
$ vagrant ssh {node1,node2}
```

The code in this repo shows up inside the VM at `/vagrant`

If you want to edit code and for it to appear in the VM:

```bash
$ vagrant rsync-auto
```

## install k8s

First we setup the master control plane:

```bash
$ vagrant ssh node1
$ sudo kubeadm init --api-advertise-addresses 172.16.255.251
```

This will take a minute or so.

In another terminal, you can watch it happen:

```bash
$ watch docker ps -a
```

Once it has finished installing the various docker components - you will see this message:

```bash
...

You can now join any number of machines by running the following on each node:

kubeadm join --token=<token> 172.16.255.251
```

To confirm the k8s api server is up and running:

```bash
$ kubectl get nodes
```

Now - install the weave network plugin:

```bash
$ kubectl apply -f https://git.io/weave-kube
```

Then - watch the pods until everything is running:

```bash
$ kubectl get po --all-namespaces -w
```

You should see something like this:

```bash
NAMESPACE     NAME                              READY     STATUS    RESTARTS   AGE
kube-system   dummy-2088944543-00jcn            1/1       Running   0          2h
kube-system   etcd-node1                        1/1       Running   0          2h
kube-system   kube-apiserver-node1              1/1       Running   0          2h
kube-system   kube-controller-manager-node1     1/1       Running   0          2h
kube-system   kube-discovery-1769846148-rkfrq   1/1       Running   0          2h
kube-system   kube-dns-2924299975-10ptv         4/4       Running   0          2h
kube-system   kube-proxy-3v3cv                  1/1       Running   0          2h
kube-system   kube-scheduler-node1              1/1       Running   0          2h
kube-system   weave-net-34gj4                   2/2       Running   0          1m
```

Now - untaint the master so it can run pods too:

```bash
$ kubectl taint nodes --all dedicated-
```

Now lets setup node2:

```bash
$ exit
$ vagrant ssh node2
$ cd /vagrant
$ sudo kubeadm join --token=<token> 172.16.255.251
```

NOTE - <token> is printed in the output of `kubeadm init` from node1

## kubectl

You can now use kubectl:

```bash
$ kubectl get po --all-namespaces
```

## reset

```
$ vagrant ssh node1
$ sudo bash /vagrant/scripts/install.sh reset
```
