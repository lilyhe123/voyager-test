#!/bin/bash
set -eu

namespace=voyager

function deleteVoyager {
  curl -fsSL https://raw.githubusercontent.com/appscode/voyager/6.0.0/hack/deploy/voyager.sh \
      | bash -s -- --provider=baremetal --namespace=$namespace --uninstall --purge
}

function installVoyager {
  local vpod=`kubectl get pod -n voyager | grep voyager | wc -l`
  if [ "$vpod" == "0" ]; then
    kubectl create namespace voyager
    curl -fsSL https://raw.githubusercontent.com/appscode/voyager/6.0.0/hack/deploy/voyager.sh \
    | bash -s -- --provider=baremetal --namespace=$namespace
  fi
}

function main() {
  if [ "$#" != 1 ] ; then
    usage
  fi

  if test $1 = "delete"; then
    deleteVoyager
  elif test $1 = "create"; then
    installVoyager  
  else
    usage
  fi
}

function usage() {
  echo "usage: $0 create|delete"
  exit 1
}

main "$@"
