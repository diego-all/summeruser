package main

import (
	"context"
	"errors"
	"fmt"
	"os"
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

	if !Validoparametros() {
		fmt.Println("Erroren los parametros, debe enviar 'SecretName'")
		err := errors.New("error en los parametros debe enviar SecretName")
		return event, err
	}

}

func Validoparametros() bool {

	var traeParametro bool
	_, traeParametro = os.LookupEnv("SecretName")
	return traeParametro
}
