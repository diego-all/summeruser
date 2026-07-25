package bd

import (
	"os"
	"summeruser/models"
	"summeruser/secretmanager"
)

var SecretModel models.SecretRDSJson
var err error

func ReadSecret() error {
	SecretModel, err := secretmanager.GetSecret(os.Getenv("SecretName"))
	return err
}
