#!/usr/bin/env bash

STACK_NAME="micheystack"
INSTANCE_TYPE="t2.micro"
DIR="/home/ec2-user/tp2-cloud-formation"
AWS_REGION="eu-west-3"

TYPE_CLOUD_FORMATION=""

if ! aws cloudformation describe-stacks --region $AWS_REGION --stack-name $STACK_NAME 
    then
    echo "1"
    TYPE_CLOUD_FORMATION='create-stack'
else
    TYPE_CLOUD_FORMATION='update-stack'
fi

if [ -z "$1" ]
  then
    echo "No STACK_NAME argument supplied"
    exit 1
fi

# Ajouter des paramètres dans les templates, de sorte à pouvoir choisir le type d'instance à utiliser, l'image à utiliser et le nom du bucket que l'on crée.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Creating stack..."
STACK_ID=$(aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://$DIR/templates/michey-stack.yml
    --parameters  file://$DIR/parameters/michey-parameters.json
    --tags file://$DIR/tags/tags.json \
    --capabilities CAPABILITY_IAM \
    | jq -r .StackId \
)

echo "Waiting on ${STACK_ID} create completion..."
aws cloudformation wait stack-create-complete --stack-name ${STACK_ID}
aws cloudformation describe-stacks --stack-name ${STACK_ID} | jq .Stacks[0].Outputs