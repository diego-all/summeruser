# summeruser
summeruser

    terraform init
    terraform apply
    terraform destroy

- Por que no aparece el: Cognito Sync Trigger (Cajita)

> Cognito Sync es un servicio legacy que AWS dejó de habilitar para identity pools nuevos. Ese servicio (el que generaba streams/push sync y por eso aparecía como una caja de "trigger" real en la consola de Lambda) fue deprecado por Amazon hace varios años. En cuentas y pools creados hoy, aunque el permiso IAM exista, la consola de Lambda simplemente no tiene nada que mostrar ahí porque el "evento" de Cognito Sync ya no se genera del lado de Cognito.

— ese sí está activo (se ve en tu plan y en el permiso AllowCognitoPostConfirmation, que se creó sin error). Ese trigger tampoco aparece nunca como una "caja" en la lista de Desencadenadores de Lambda (imagen 3, "Triggers (0)") — eso es normal: los triggers de User Pool (post-confirmation, pre-sign-up, etc.) se configuran y viven del lado de Cognito, no se reflejan en la lista de triggers de la función Lambda. Así que no te falta nada ahí; la ausencia de esa caja es esperada en tu cuenta.

    mysql -h summer.c87semo4ses5.us-east-1.rds.amazonaws.com -P 3306 -u root -p --ssl-mode=VERIFY_IDENTITY --ssl-ca=./global-bundle.pem summer < gambit_copy.sql


Ingresar a la base de datos

    mysql -h summer.c87semo4ses5.us-east-1.rds.amazonaws.com -P 3306 -u root -p --ssl-mode=VERIFY_IDENTITY --ssl-ca=./global-bundle.pem -A summer



### Recompilar la lambda**

    GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -tags lambda.norpc -o bootstrap main.go

    zip function.zip bootstrap


### 

cómo funciona Cognito como Identity Provider.


### Terraform

    terraform fmt
    terraform validate
    terraform plan -out=tfplan
    terraform apply tfplan






https://localhost:3000/#id_token=eyJraWQiOiJBakZYRThPSGt5ZVJjZnZWL1hDVkt2eHFyN2pIY29hem8zV2tTemYrTnRZPSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoiMkFEVWNGbTZTdWg1dkRUSHFqR2FCQSIsInN1YiI6ImM0NTg0NDY4LTIwZjEtNzBmMi1kZjJjLTUxNDI2NDdiMDkyNCIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc3MiOiJodHRwczovL2NvZ25pdG8taWRwLnVzLWVhc3QtMS5hbWF6b25hd3MuY29tL3VzLWVhc3QtMV9RSlpWRzRSUnEiLCJjb2duaXRvOnVzZXJuYW1lIjoiYzQ1ODQ0NjgtMjBmMS03MGYyLWRmMmMtNTE0MjY0N2IwOTI0IiwiYXVkIjoiMzhoMGQ2ZmlsZTNhNWhwcWVqMWE3czJubTQiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTc5MTg3MDYxNiwiZXhwIjoxNzkxOTU3MDE2LCJpYXQiOjE3OTE4NzA2MTcsImp0aSI6IjdlZTE2YzFlLWFmOGMtNGExYi04YWY2LThmNTVlZDc0ZmMzNCIsImVtYWlsIjoiZHBvc2FkYWxsYW5vK3Rlc3QxQGhvdG1haWwuY29tIn0.dxUSpQYIGQPPX7G8vxh9KJ7uYVs3tWWKuH3MNXqEVy2XSFA-5Lktu8ecHdjheirgm2_GYtcqba5do3uYHpfI_BpY307r_Uq8uUzqfKN1hVS5sbo3dDG0hJYVQFq0c9e2V_L3jaoQiDHNwM0edMADq48mx-OTxy9U0D1Qtm-3jxsJjv8T66_PlD07FYhNgjaZgPyY45rdNMORXzMYcPl69OLSzeZrI0tSbi4iU85wsSQUuvYF7ynyfuWTR8Lj9CJfI1f4DsZezM7sqN9k_FsixzU6NdWp_PxjZ29h0OnUhE53uWqsaAYuRQNZDrVME7Tvsbw8chwMpcw9iIBNaM12Fg&access_token=eyJraWQiOiIvMGw4T3o5cmgxY0IrR0tyZWMwallsaStBTzVOazRueWJsTm44MFZuOTRVPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJjNDU4NDQ2OC0yMGYxLTcwZjItZGYyYy01MTQyNjQ3YjA5MjQiLCJ0b2tlbl91c2UiOiJhY2Nlc3MiLCJzY29wZSI6Im9wZW5pZCBlbWFpbCIsImF1dGhfdGltZSI6MTc5MTg3MDYxNiwiaXNzIjoiaHR0cHM6Ly9jb2duaXRvLWlkcC51cy1lYXN0LTEuYW1hem9uYXdzLmNvbS91cy1lYXN0LTFfUUpaVkc0UlJxIiwiZXhwIjoxNzkxOTU3MDE2LCJpYXQiOjE3OTE4NzA2MTcsInZlcnNpb24iOjIsImp0aSI6IjE1NzExYTM0LTczMGMtNDczMC1iYWVjLTgwZTE4MzJiYjQwYyIsImNsaWVudF9pZCI6IjM4aDBkNmZpbGUzYTVocHFlajFhN3Mybm00IiwidXNlcm5hbWUiOiJjNDU4NDQ2OC0yMGYxLTcwZjItZGYyYy01MTQyNjQ3YjA5MjQifQ.Ihnvpzv0aFkAabvle-Ub3pss6D1cvJ9hkg2p1ZbZhPEHrIKBgxWxGBOK9jbdVBAzMir7pvlSgpDN-kpbkkLyOKYFOA3hyc1jyCe4szE4lyEatAhfi5wto8qS1dxYHuK-PlD8FMrMZI98F-mfdmAVm0R308eX56DQ1VzgZ3qIjDTKNTsRCK2p08WCjuYJSUkzt5Lb4T71fU8QMRDSi5DZkReoH3j3oubndcFPRb_te81qATg3mtualf7MOGyhQGRMvPXRz5RqTvVaLXrapRxzAmO3rbq-IEewOYA3PuRkXd8mxQck8MlI1veFsYGC2x-cM6OYLK7hyW_zlKUaPfzgQA&expires_in=86400&token_type=Bearer