package main

import (
	"context"
	"summeruser/awsgo"

	lambda "github.com/aws/aws-lambda-go/lambda"
	// go get github.com/aws/aws-lambda-go/events
	"github.com/aws/aws-lambda-go/events"
	//summeruser/awsgo
)

func main() {

	lambda.Start(EjecutoLambda)

}

func EjecutoLambda(ctx context.Context, event events.CognitoEventUserPoolsPostConfirmation) (events.CognitoEventUserPoolsPostConfirmation, error) {
	awsgo.InicializoAWS()
}
