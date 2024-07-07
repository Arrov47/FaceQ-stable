package CheckGroupsJSON

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
)

func CheckGroups() error {
	filename := "groups.json"

	// Проверка наличия файла
	if _, err := os.Stat(filename); os.IsNotExist(err) {
		// Если файла нет, создаем его с некоторыми данными
		fmt.Println("Файл не существует. Создаем файл...")

		groups := map[string][]string{"groups": []string{}}

		jsonData, err := json.MarshalIndent(groups, "", " ")
		if err != nil {
			fmt.Println("Ошибка при маршалинге JSON:", err)
			return err
		}

		err = ioutil.WriteFile(filename, jsonData, 0644)
		if err != nil {
			fmt.Println("Ошибка при записи файла:", err)
			return err
		}

		fmt.Println("Файл успешно создан с данными.")
	} else {
		fmt.Println("Файл уже существует.")
	}
	return nil
}
