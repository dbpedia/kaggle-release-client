#!/bin/bash

# get all variables and functions
source functions.sh

TASK=$1
ACCOUT_GROUP_ID=$2
VERSION=$3

###################
# Check arguments
###################


case $TASK in

  deploy)
	if [ -z "$ACCOUT_GROUP_ID" ] && [ -z "$VERSION" ]
	then
	      echo "Missing one of the argumennts - account/group or version argument , e.g. ./kaggle-release.sh deploy m1ci/text 2020.02.01"
	else
	    echo "[INFO] Deploying all datasets found under m1ci/text."
	    deploy $ACCOUT_GROUP_ID $VERSION
	fi
    ;;

  *)
    echo "Please specify the deploy command, e.g. ./kaggle-release.sh deploy m1ci/text 2020.02.01"
    ;;
esac






