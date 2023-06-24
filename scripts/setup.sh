#!/bin/sh

source ./scripts/env.sh

# This will create docker container for localstack
docker-compose up -d

[ $? == 0 ] || fail 1 "Failed: Docker / compose / up"


# Building for lambda's architecture: linux/amd64
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${QUEUE_HANDLER} .

[ $? == 0 ] || fail 2 "Failed: Go / build / ${QUEUE_HANDLER}"


zip -r ${QUEUE_HANDLER}.zip ${QUEUE_HANDLER}

[ $? == 0 ] || fail 3 "Failed: zip / ${QUEUE_HANDLER}"


OUTPUT=$(awslocal lambda create-function \
    --region ${AWS_REGION} \
    --function-name ${LAMBDA_NAME} \
    --runtime go1.x \
    --handler ${QUEUE_HANDLER} \
    --timeout 30 \
    --memory-size 128 \
    --zip-file fileb://${QUEUE_HANDLER}.zip \
    --role "arn:aws:iam::000000000000:role/irrelevant" \
    --environment "Variables={$ENVS}") # Passing variables read from .env

[ $? == 0 ] || fail 4 "Failed: AWS / lambda / create-function"


QUEUE_URL=$(awslocal sqs create-queue \
                 --queue-name ${QUEUE_NAME} \
                 --region ${AWS_REGION} \
                 --attributes "{\"FifoQueue\":\"true\",\"ContentBasedDeduplication\":\"false\"}" \
                 --query "QueueUrl" \
                 --output text)

[ $? == 0 ] || fail 5 "Failed: AWS / sqs / create-queue"


QUEUE_ARN=$(awslocal sqs get-queue-attributes \
	--queue-url ${QUEUE_URL} \
	--region ${AWS_REGION} \
	--attribute-names QueueArn \
	--query "Attributes.QueueArn" \
	--output text)


OUTPUT=$(awslocal lambda create-event-source-mapping \
    --function-name ${LAMBDA_NAME} \
    --event-source-arn ${QUEUE_ARN} \
    --region us-west-2)

[ $? == 0 ] || fail 6 "Failed: AWS / lambda / create-event-source-mapping"


echo "Sending message and testing queue handler..."
./scripts/test.sh
