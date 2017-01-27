#!/usr/bin/env bash

set -e

export NODE1="172.16.255.251"
export NODE2="172.16.255.252"

function ensure_root() {
  if [ "$(id -u)" != "0" ]; then
     echo "This script must be run as root" 1>&2
     exit 1
  fi
}


# enable cgroup sharing then reboot
function grub() {

  ensure_root

  cat <<EOF > /etc/default/grub
GRUB_DEFAULT=0
GRUB_TIMEOUT=1
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US cgroup_enable=memory swapaccount=1"
EOF

  update-grub

  cat <<EOF

GRUB updated - restart both VMS

$ vagrant halt
$ vagrant up

EOF
}

# install base deps
function basedeps() {
  apt-get update
  apt-get install -y \
    curl \
    apt-transport-https \
    ca-certificates \
    software-properties-common
}

# install docker
function docker() {
  curl -fsSL https://yum.dockerproject.org/gpg | sudo apt-key add -
  add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       debian-$(lsb_release -cs) \
       main"
  apt-get update
  apt-get -y install docker-engine
  usermod -a -G docker vagrant
}

# install base k8s binaries
function k8s() {
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
  apt-get update
  apt-get install -y \
    kubelet \
    kubeadm \
    kubectl \
    kubernetes-cni
}

# install everything for one node
function bootstrap() {
  hostnames
  sshkeys
  basedeps
  docker
  k8s
  grub
}

function reset() {
  exec kubeadm reset
  rm -rf /etc/kubernetes/
  rm -rf /var/lib/kubelet
  rm -rf /var/lib/etcd
  exec docker rm -f $(exec docker ps -aq)
}

function usage() {
cat <<EOF
Usage:
  hostnames            append to /etc/hosts for {node1,node2}
  sshkeys              install the ssh keys so we can ssh vagrant@{node1,node2}
  basedeps             install base deps
  docker               install docker
  k8s                  install base k8s binaries
  grub                 upate grub
  bootstrap            install everything for one node
  reset                revert to pre install k8s
  help                 display this message
EOF
  exit 1
}

function main() {
  case "$1" in
  hostnames)        shift; hostnames $@;;
  sshkeys)          shift; sshkeys $@;;
  basedeps)         shift; basedeps $@;;
  docker)           shift; docker $@;;
  k8s)              shift; k8s $@;;
  grub)             shift; grub $@;;
  bootstrap)        shift; bootstrap $@;;
  reset)            shift; reset $@;;
  *)                usage $@;;
  esac
}

ensure_root
main "$@"