#!/bin/bash
set -eu

VOYAGER_NAMESPACE=voyager

namespace=default
domainUID=domain1
domainName=base_domain
clusterNameLC=cluster-1
managedServerPort=8001
inputYaml=voyager-ingress-template.yaml
voyagerOutput=${domainUID}-voyager-ingress.yaml
loadBalancerWebPort=30305
loadBalancerDashboardPort=30315

function delete() {
    kubectl delete apiservice -l app=voyager
    # delete voyager operator
    kubectl delete deployment -l app=voyager --namespace $VOYAGER_NAMESPACE
    kubectl delete service -l app=voyager --namespace $VOYAGER_NAMESPACE
    kubectl delete secret -l app=voyager --namespace $VOYAGER_NAMESPACE
    # delete RBAC objects, if --rbac flag was used.
    kubectl delete serviceaccount -l app=voyager --namespace $VOYAGER_NAMESPACE
    kubectl delete clusterrolebindings -l app=voyager
    kubectl delete clusterrole -l app=voyager
    kubectl delete rolebindings -l app=voyager --namespace $VOYAGER_NAMESPACE
    kubectl delete role -l app=voyager --namespace $VOYAGER_NAMESPACE
}

function create() {
    kubectl create namespace $VOYAGER_NAMESPACE
    kubectl create serviceaccount voyager-operator --namespace $VOYAGER_NAMESPACE
    kubectl label serviceaccount voyager-operator app=voyager --namespace $VOYAGER_NAMESPACE
    kubectl auth reconcile -f rbac-list.yaml
    kubectl auth reconcile -f user-roles.yaml 
    kubectl apply -f operator.yaml
}

function generateYaml() {
    cp $inputYaml $voyagerOutput
    sed -i -e "s:%NAMESPACE%:$namespace:g" ${voyagerOutput}
    sed -i -e "s:%DOMAIN_UID%:${domainUID}:g" ${voyagerOutput}
    sed -i -e "s:%DOMAIN_NAME%:${domainName}:g" ${voyagerOutput}
    sed -i -e "s:%CLUSTER_NAME_LC%:${clusterNameLC}:g" ${voyagerOutput}
    sed -i -e "s:%MANAGED_SERVER_PORT%:${managedServerPort}:g" ${voyagerOutput}
    sed -i -e "s:%LOAD_BALANCER_WEB_PORT%:$loadBalancerWebPort:g" ${voyagerOutput}
    sed -i -e "s:%LOAD_BALANCER_DASHBOARD_PORT%:$loadBalancerDashboardPort:g" ${voyagerOutput}

}


function main() {
  if [ "$#" != 1 ] ; then
    usage
  fi

  if test $1 = "delete"; then
    delete
  elif test $1 = "create"; then
    create  
  elif test $1 = "generate"; then
    generateYaml  
  else
    usage
  fi
}

function usage() {
  echo "usage: $0 create|delete|generate"
  exit 1
}

main "$@"
