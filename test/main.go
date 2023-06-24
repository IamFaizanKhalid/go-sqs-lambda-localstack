package main

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/joho/godotenv"
	"log"
	"math/rand"
	"strconv"
	"time"
)

func main() {
	godotenv.Load(".env")

	//queueName := os.Getenv("QUEUE_NAME")

	cfg := &aws.Config{
		Endpoint:   aws.String("http://localhost:4566"),
		Region:     aws.String("us-west-2"),
		DisableSSL: aws.Bool(true),
	}

	client := sqs.New(session.Must(session.NewSession(cfg)))

	result, err := client.GetQueueUrl(&sqs.GetQueueUrlInput{
		QueueName: aws.String("my-queue.fifo"),
	})
	if err != nil {
		log.Fatalln(err)
	}

	queueUrl := result.QueueUrl

	_, err = client.SendMessage(
		&sqs.SendMessageInput{
			MessageBody:            aws.String(time.Now().Format(time.RFC850)),
			MessageGroupId:         aws.String("test"),
			MessageDeduplicationId: aws.String(strconv.Itoa(rand.Int())),
			QueueUrl:               queueUrl,
		})
	if err != nil {
		log.Fatalln(err)
	}

	log.Println("message sent...")
}
