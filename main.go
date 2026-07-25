package main

import (
	"context"
	"errors"
	"fmt"
	"os"
	"summeruser/awsgo"
	"summeruser/bd"
	"summeruser/models"

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

	// Cognito: Viene un evento con el post-confirmation
	var datos models.SignUp

	for row, att := range event.Request.UserAttributes {

		switch row {
		case "email":
			datos.UserEmail = att
			fmt.Println("Email = " + datos.UserEmail)
		case "sub":
			datos.UserUUID = att
			fmt.Println("Sub = " + datos.UserUUID)
		}

	}

	err := bd.ReadSecret()
	if err != nil {
		fmt.Println("Error al leer el Secret " + err.Error())
		return event, err
	}

}

func Validoparametros() bool {

	var traeParametro bool
	_, traeParametro = os.LookupEnv("SecretName")
	return traeParametro
}
