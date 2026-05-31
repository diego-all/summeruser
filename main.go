package main

import (
	lambda "github.com/aws/aws-lambda-go/lambda"
	// go get github.com/aws/aws-lambda-go/events
)

func main() {

	lambda.Start(EjecutoLambda)

}

func EjecutoLambda() {

}
