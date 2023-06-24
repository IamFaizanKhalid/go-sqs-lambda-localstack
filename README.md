This demonstrates how you can configure an SQS queue in localstack, which will trigger a lambda function when a message will be received.

## Prerequisites:
- docker-compose
- [AWS CLI](https://aws.amazon.com/cli/)

## Usage
- Run `./scripts/setup.sh` to set up.
- Run `./scripts/test.sh` to send a message in the queue and see lambda executions logs to check if the message was received.
- Run `./scripts/update.sh` to update lambda with your latest code.
