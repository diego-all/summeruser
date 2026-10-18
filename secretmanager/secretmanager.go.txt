package secretmanager

import (

	// "github.com/aws/aws-sdk-go-v2/services/secretsmanager"
	// "github.com/summeruser/models"

	"encoding/json"
	"fmt"
	"summeruser/awsgo"
	"summeruser/models"

	// "summeruser/secretmanager"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	// "github.com/summeruser/models"
)

func GetSecret(nombreSecret string) (models.SecretRDSJson, error) {

	var datosSecret models.SecretRDSJson
	fmt.Println("Pido Secreto" + nombreSecret)

	svc := secretsmanager.NewFromConfig(awsgo.Cfg)
	clave, err := svc.GetSecretValue(awsgo.Ctx, &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(nombreSecret),
	})

	// Se envia a cloudwatch el error directamente sin ningun mensaje.
	if err != nil {
		fmt.Println(err.Error())
		return datosSecret, err
	}

	// collecion de bytes, conversion implicita

	json.Unmarshal([]byte(*clave.SecretString), &datosSecret)
	fmt.Println("lectura Secret OK " + nombreSecret)
	return datosSecret, nil
}
