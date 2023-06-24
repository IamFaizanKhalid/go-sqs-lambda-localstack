#!/bin/sh

source ./scripts/env.sh

#awslocal sqs send-message \
#	--queue-url $QUEUE_URL \
#	--message-group-id test \
#	--message-deduplication-id "${TIMESTAMP}" \
#	--message-body "${TIMESTAMP}"

go run ./test

sleep 10

awslocal logs tail /aws/lambda/${LAMBDA_NAME}
