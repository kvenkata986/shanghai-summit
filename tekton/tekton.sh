#!/bin/bash
set -e

function deploy_tekton () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)====================== Deploying Tekton =======================$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Install Tekton
  kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.7.0/release.yaml
  set +e
  # NOTE: Wait for deploy
  ../utils/wait-for-pods.sh tekton
  set -e
}

function  docker_registry () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)======= Create Secret For DockerHub and Service Account =======$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Note: This yaml file creates Secret, which is used to store your DockerHub credentials
  kubectl apply --filename secret.yaml
  # Note: Thic yaml files creates Service Account, which is used to link the build process to the secret
  kubectl apply --filename serviceacount.yaml

}

function create_PipelineResource () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)======= Create Pipeline Resource For Git and DockerHub ========$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Note: This file creates Pipeline Resource for Git
  kubectl apply --filename prg.yaml
  # Note: This file creates Pipeline Resource for DockerHub
  kubectl apply --filename prd.yaml
}

function create_Task () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)======= Create Task  ========$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Note: This create Pipeline Resource for Git
  kubectl apply --filename ./task.yaml
}

function create_TaskRun () {
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  echo "$(tput setaf 2)======= Create TaskRun ========$(tput setaf 9)"
  echo "$(tput setaf 2)===============================================================$(tput setaf 9)"
  # Note: This create Pipeline Resource for Git
  if [ -z $name ]
    then
      echo "name variable not set, using default summit01"
    else
      sed -i 's/summit01/'"$name"'/' ./taskrun.yaml
  fi
  kubectl apply --filename ./taskrun.yaml
}

usage() {
  echo "Usage:  ./tekton.sh deploy_tekton"
  echo "        ./tekton.sh docker_registry"
  echo "        ./tekton.sh create_PipelineResource"
  echo "        ./tekton.sh create_Task"
  echo "        ./tekton.sh create_TaskRun"
  exit 1
}

if [ $# -eq 0 ]; then
  usage
else
  USERNAME=$1
  PASSWORD=$2
  EMAIL=$3
  case $1 in
    deploy_tekton ) deploy_tekton
    ;;
    docker_registry ) docker_registry
    ;;
    create_PipelineResource ) create_PipelineResource
    ;;
    create_Task ) create_Task
    ;;
    create_TaskRun ) create_TaskRun
    ;;
    *)
    usage
    exit 1
    ;;
    esac
fi

