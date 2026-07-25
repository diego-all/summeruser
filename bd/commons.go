package bd

import (
	"database/sql"
	"fmt"
	"os"
	"summeruser/models"
	"summeruser/secretmanager"

	_ "github.com/go-sql-driver/mysql" // Por que con blank space?
)

var SecretModel models.SecretRDSJson
var err error
var Db *sql.DB

func ReadSecret() error {
	SecretModel, err = secretmanager.GetSecret(os.Getenv("SecretName"))
	return err
}

func DbConnect() error {

	Db, err = sql.Open("mysql", ConnStr(SecretModel))
	if err != nil {
		fmt.Println(err.Error())
		return err
	}

	err := Db.Ping()
	if err != nil {
		fmt.Println(err.Error())
		return err
	}

	fmt.Println("Conexion exitosa a la base de datos.")
	return nil
}

func ConnStr(claves models.SecretRDSJson) string {

	var dbUser, authToken, dbEndpoint, dbName string
	dbUser = claves.Username
	authToken = claves.Password
	dbEndpoint = claves.Host
	dbName = "gambit"
	dsn := fmt.Sprintf("%s:%s@tcp(%s)/%s?allowCleartextPasswords=true", dbUser, authToken, dbEndpoint, dbName)
	// Pesima practica, queda en cloudwatch
	fmt.Println(dsn)

	return dsn
}
