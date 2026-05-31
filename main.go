package main

import (
	"context"

	lambda "github.com/aws/aws-lambda-go/lambda"
	// go get github.com/aws/aws-lambda-go/events
	"github.com/aws/aws-lambda-go/events"
)

func main() {

	lambda.Start(EjecutoLambda)

}

func EjecutoLambda(ctx context.Context, event events.CognitoEventUserPoolsPostConfirmation) (events.CognitoEventUserPoolsPostConfirmation, error) {

}
