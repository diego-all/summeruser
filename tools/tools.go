package tools

import (
	"fmt"
	"time"
)

// Nombre con Mayúscula para ser exportada (pública)
func FechaMySQL() string {
	t := time.Now()

	// Paréntesis corregido al final de la línea
	return fmt.Sprintf("%d-%02d-%02dT%02d:%02d:%02d",
		t.Year(), t.Month(), t.Day(), t.Hour(), t.Minute(), t.Second())
}
