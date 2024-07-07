package GetDesktopAddress

import (
	"fmt"
	"os"
	"os/user"
	"path/filepath"
	"runtime"
)

func GetDesktopAddress() (string, error) {
	usr, err := user.Current()
	if err != nil {
		return "", err
	}

	var desktopPath string
	if runtime.GOOS == "windows" {
		desktopPath = filepath.Join(usr.HomeDir, "Desktop")
	} else {
		return "", fmt.Errorf("Неизвестная операционная система ")
	}

	if _, err := os.Stat(desktopPath); os.IsNotExist(err) {
		fmt.Println("Рабочий стол не найден:", desktopPath)
	} else {
		fmt.Println("Путь к рабочему столу:", desktopPath)
		return desktopPath, nil
	}
	return "", err
}
