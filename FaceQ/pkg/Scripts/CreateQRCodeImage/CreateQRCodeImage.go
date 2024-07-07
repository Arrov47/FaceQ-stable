package CreateQRCodeImage

import (
	"path/filepath"

	"github.com/skip2/go-qrcode"
)

func CreateQRCodeImage(pathToSave string, text string, filename string) error {
	// Полный путь к файлу
	filePath := filepath.Join(pathToSave, filename)

	// Генерация QR-кода и сохранение в файл
	err := qrcode.WriteFile(text, qrcode.Medium, 256, filePath)
	if err != nil {
		return err
	}
	return nil
}
