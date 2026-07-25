package bd

import (
	"fmt"
	"summeruser/models"

	// "summeruser/tools"
	"summeruser/tools"
)

func SignUp(sig models.SignUp) error {
	fmt.Println("Comienza Registro")

	err := DbConnect()
	if err != nil {
		return err
	}

	defer Db.Close()

	sentencia := "INSERT INTO users (User_email, User_UUID, User_DateAdd) VALUES ('" + sig.UserEmail + "'.'" + sig.UserUUID + "','" + tools.FechaMySQL() + "')"
	fmt.Println(sentencia)

	_, err = Db.Exec(sentencia)
	if err != nil {
		fmt.Println(err.Error())
		return err
	}

	fmt.Println("Signup Ejecucion Exitosa")
	return nil

}
