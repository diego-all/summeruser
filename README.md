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


