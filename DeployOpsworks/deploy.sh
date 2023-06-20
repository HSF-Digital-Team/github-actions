#!/bin/sh

set -e

#variable a setup :
REGION=$AWS_REGION
STACK_NAME=$AWS_STACK_NAME
MESSAGE="Deploy on stack $STACK_NAME"

debug () {
    echo "$1" >&2
}

wait_for_deployment () {
  DEPLOYMENT_ID=$1
  debug "$MESSAGE: waiting for deployment $DEPLOYMENT_ID..."
  STATUS=$(aws opsworks describe-deployments --region $REGION --deployment-id $DEPLOYMENT_ID --query "Deployments|[0].Status" --output text) || exit 1
  for retry in `seq 1 90`; do
    if [ "$STATUS" = "running" ]; then
      sleep 10
      STATUS=$(aws opsworks describe-deployments --region $REGION --deployment-id $DEPLOYMENT_ID --query "Deployments|[0].Status" --output text) || exit 1
      debug "Deployment $DEPLOYMENT_ID: $STATUS"
    fi
  done
  if [ "$STATUS" != "successful" ]; then
    debug "Failed to deploy $DEPLOYMENT_ID, status $STATUS - aborting"
    exit 1
  fi
}


deploy () {
  #We retrieve the stack ID
  STACK_ID=$(aws opsworks describe-stacks $REGION_SNIPPET --query "Stacks[].{StackId:StackId, Name: Name}[?Name=='$STACK_NAME'] | [0].StackId" --output text)
  debug "Stackid : $STACK_ID"
  #we retrieve the App ID
  APP_ID=$(aws opsworks describe-apps --stack-id $STACK_ID --query "Apps[].{AppId:AppId}| [0].AppId" --output text)
  debug "Appid : $APP_ID"
  #We Launch the deployment and wait for result
  DEPLOYMENT_ID=$(aws opsworks create-deployment --region $REGION --stack-id $STACK_ID --app-id $APP_ID --command "{\"Name\":\"deploy\"}" --output text)
  wait_for_deployment $DEPLOYMENT_ID || exit 1
}


deploy
