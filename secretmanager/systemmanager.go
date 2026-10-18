package secretmanager

import (
	"encoding/json"
	"fmt"
	"summeruser/awsgo"
	"summeruser/models"

	"github.com/aws/aws-sdk-go-v2/aws"
	// CAMBIO: Parameter Store (Systems Manager) en vez de Secrets Manager (que cobra por secreto)
	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

// Se mantiene el nombre GetSecret para no tocar a quienes la llaman (bd.ReadSecret).
// "nombreSecret" ahora es el nombre del parámetro (variable de entorno SecretName = /summer/db).
func GetSecret(nombreSecret string) (models.SecretRDSJson, error) {

	var datosSecret models.SecretRDSJson
	fmt.Println("Pido Secreto " + nombreSecret)

	svc := ssm.NewFromConfig(awsgo.Cfg)
	clave, err := svc.GetParameter(awsgo.Ctx, &ssm.GetParameterInput{
		Name:           aws.String(nombreSecret),
		WithDecryption: aws.Bool(true), // el parámetro es SecureString
	})
	if err != nil {
		fmt.Println(err.Error())
		return datosSecret, err
	}

	// El JSON viene en Parameter.Value (antes SecretString)
	err = json.Unmarshal([]byte(*clave.Parameter.Value), &datosSecret)
	if err != nil {
		fmt.Println("Error al parsear el parámetro: " + err.Error())
		return datosSecret, err
	}

	fmt.Println("lectura Secret OK " + nombreSecret)
	return datosSecret, nil
}
