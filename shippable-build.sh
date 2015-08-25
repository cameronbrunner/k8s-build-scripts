#!/bin/bash
set -x

export KUBE_TEST_API_VERSIONS=v1 KUBE_TEST_ETCD_PREFIXES=registry
export BASE_BRANCH=

source $HOME/.gvm/scripts/gvm

mkdir -p /scratch/build/src/k8s.io
ln -s /scratch/src/kubernetes /scratch/build/src/k8s.io/kubernetes
cd /scratch/build

gvm install go1.4
gvm use go1.4
cd /scratch/build/src/k8s.io/kubernetes

./hack/travis/install-etcd.sh
export GOPATH=/scratch/build

export PATH=$GOPATH/bin:./third_party/etcd:$PATH

go get golang.org/x/tools/cmd/cover
go get github.com/mattn/goveralls
go get github.com/tools/godep
./hack/build-go.sh
godep go install ./...
./hack/travis/install-etcd.sh
./hack/verify-gofmt.sh
./hack/verify-boilerplate.sh
./hack/verify-description.sh
./hack/verify-flags-underscore.py
./hack/verify-godeps.sh ${BASE_BRANCH}
./hack/travis/install-std-race.sh
./hack/verify-generated-conversions.sh
./hack/verify-generated-deep-copies.sh
./hack/verify-generated-docs.sh
./hack/verify-swagger-spec.sh
./hack/verify-linkcheck.sh

