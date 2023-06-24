#!/bin/sh

source ./scripts/env.sh

GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${QUEUE_HANDLER} .

[ $? == 0 ] || fail 1 "Failed: Go / build / ${QUEUE_HANDLER}"


zip -r ${QUEUE_HANDLER}.zip ${QUEUE_HANDLER}

[ $? == 0 ] || fail 2 "Failed: zip / ${QUEUE_HANDLER}"


OUTPUT=$(awslocal lambda update-function-code \
		--function-name ${LAMBDA_NAME} \
		--zip-file fileb://${QUEUE_HANDLER}.zip)

[ $? == 0 ] || fail 3 "Failed: AWS / lambda / update-function-code"

echo "Lambda code updated..."
