#!/bin/bash

# Variables
CLUSTER_NAME="my-ecs-cluster"
SERVICE_NAME="my-ecs-service"
TASK_DEFINITION_NAME="my-ecs-task"
CONTAINER_NAME="my-app-container"
DOCKER_IMAGE="my-dockerhub-username/my-app:latest"
REGION="us-east-1"
ROLE_ARN="arn:aws:iam::123456789012:role/ecsTaskExecutionRole" # Update with your role ARN
SUBNET_ID="subnet-0bb1c79de3EXAMPLE" # Update with your subnet ID
SECURITY_GROUP_ID="sg-085912345678492fb" # Update with your security group ID

# Create ECS cluster
aws ecs create-cluster --cluster-name $CLUSTER_NAME --region $REGION

# Register task definition
TASK_DEFINITION=$(cat <<EOF
{
  "family": "$TASK_DEFINITION_NAME",
  "networkMode": "awsvpc",
  "containerDefinitions": [
    {
      "name": "$CONTAINER_NAME",
      "image": "$DOCKER_IMAGE",
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ],
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "$ROLE_ARN"
}
EOF
)

echo "$TASK_DEFINITION" > task_definition.json
aws ecs register-task-definition --cli-input-json file://task_definition.json

# Create ECS service
aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --task-definition $TASK_DEFINITION_NAME \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_ID],securityGroups=[$SECURITY_GROUP_ID],assignPublicIp=ENABLED}" \
    --region $REGION

echo "Deployment to ECS completed successfully."

