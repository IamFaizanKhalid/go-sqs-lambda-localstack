package main

import (
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(queueHandler)
}

func queueHandler(e events.SQSEvent) {
	for _, message := range e.Records {
		log.Println("Message received: ", message.Body)
	}
}
