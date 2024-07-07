package Service

import (
	"FaceQ/internal/adapters/db/sqlite/admin"
	"FaceQ/internal/adapters/db/sqlite/user"
	"FaceQ/internal/domain/entity"
	"encoding/json"
	"fmt"
	"github.com/google/uuid"
	"io"
	"mime/multipart"
	"net/http"
	"reflect"
)

//type AdminService interface {
//	LookDates(dates entity.LookDates) (entity.LookDatesResult, error)
//	Login(admin entity.Admin) (entity.CommonResult, error)
//	ChangePassword(password entity.ChangePassword) (entity.CommonResult, error)
//	AddUser(full entity.UserFull) (entity.CommonResult, error)
//	DeleteUser(user entity.DeleteUser) (entity.CommonResult, error)
//	AddGroup(group entity.AddGroup) (entity.CommonResult, error)
//	DeleteGroup(group entity.DeleteGroup) (entity.CommonResult, error)
//}

type AdminServiceObject struct {
	userStorage  user.Storage
	adminStorage admin.Storage
}

func NewAdminService(userStorage user.StorageObject, adminStorage admin.StorageObject) (AdminServiceObject, error) {
	return AdminServiceObject{
		userStorage:  userStorage,
		adminStorage: adminStorage,
	}, nil
}

func (s AdminServiceObject) CheckToken(w http.ResponseWriter, r *http.Request) {
	var checkToken entity.CheckToken
	err := json.NewDecoder(r.Body).Decode(&checkToken)
	if err != nil {
		http.Error(w, "Wrong JSON struct", http.StatusBadRequest)
		return
	}
	token, err := s.adminStorage.CheckToken(checkToken.Token)

	resp, err := json.Marshal(entity.CommonResult{IsValid: token})
	if err != nil {
		http.Error(w, "Something went wrong", http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusOK)
	_, err = w.Write(resp)
	if err != nil {
		return
	}
}
func (s AdminServiceObject) GetContact(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Failed to read request body", http.StatusInternalServerError)
			return
		}

		var data map[string]interface{}
		err = json.Unmarshal(body, &data)
		if err != nil {
			http.Error(w, "Failed to parse body", http.StatusBadRequest)
			return
		}
		fmt.Printf("Received data: %v\n", data)

		if isOK, err := s.adminStorage.CheckToken(data["token"].(string)); isOK == false {
			fmt.Println(err)
			http.Error(w, "Missing 'token' field ", http.StatusBadRequest)
			return
		}

		contact := map[string]interface{}{
			"Azim":  []string{"+99362166389"},
			"Artur": []string{"+99362166789"},
		}
		w.WriteHeader(http.StatusOK)
		resp, err := json.Marshal(contact)
		_, err = w.Write(resp)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	}
}

func (s AdminServiceObject) GetGroups(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Failed to read request body", http.StatusInternalServerError)
			return
		}

		var data map[string]string
		err = json.Unmarshal(body, &data)
		if err != nil {
			http.Error(w, "Failed to parse body", http.StatusBadRequest)
			return
		}

		if isOK, err := s.adminStorage.CheckToken(data["token"]); isOK == false {
			w.WriteHeader(200)
			err = json.NewEncoder(w).Encode(entity.GetGroupsResult{Groups: []string{}, IsValid: false, IsTokenValid: false})
			if err != nil {
				fmt.Println(err)
			}
			return
		}

		fmt.Printf("Received data: %v\n", data)

		keys := s.GetAllKeys(data)
		tags := s.GetJSONTags(entity.GetGroups{})
		JSONTruth := s.ContainsAll(tags, keys)
		if JSONTruth {
			getGroupsResult, err := s.userStorage.GetGroups()
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			w.WriteHeader(http.StatusOK)
			resp, err := json.Marshal(getGroupsResult)
			_, err = w.Write(resp)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
		} else {
			http.Error(w, "Method not allowed ", http.StatusMethodNotAllowed)
			return
		}
	}
}

func (s AdminServiceObject) LookDates(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Failed to read request body", http.StatusInternalServerError)
			return
		}

		var data map[string]string
		err = json.Unmarshal(body, &data)
		if err != nil {
			http.Error(w, "Failed to parse body", http.StatusBadRequest)
			return
		}
		fmt.Printf("Received data: %v\n", data)

		if isOK, err := s.adminStorage.CheckToken(data["token"]); isOK == false {
			w.WriteHeader(200)
			err = json.NewEncoder(w).Encode(entity.LookDatesResult{Data: [][]interface{}{}, IsTokenValid: false, IsValid: false})
			if err != nil {
				fmt.Println(err)
			}
			return
		}

		keys := s.GetAllKeys(data)
		tags := s.GetJSONTags(entity.LookDates{})
		JSONTruth := s.ContainsAll(tags, keys)
		if JSONTruth {
			var lookDates entity.LookDates
			err = json.Unmarshal(body, &lookDates)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			lookDatesResult, err := s.userStorage.LookDates(lookDates)
			fmt.Println(lookDates)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			w.WriteHeader(http.StatusOK)
			resp, err := json.Marshal(lookDatesResult)
			_, err = w.Write(resp)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
		} else {
			http.Error(w, "Method not allowed ", http.StatusMethodNotAllowed)
			return
		}
	}

}

func (s AdminServiceObject) Login(w http.ResponseWriter, r *http.Request) {

	if r.Method == "POST" {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Failed to read request body", http.StatusInternalServerError)
			return
		}

		var data map[string]string
		err = json.Unmarshal(body, &data)
		if err != nil {
			http.Error(w, "Failed to parse body", http.StatusBadRequest)
			return
		}
		fmt.Printf("Received data: %v\n", data)
		keys := s.GetAllKeys(data)
		tags := s.GetJSONTags(entity.AdminLogin{})
		JSONTruth := s.ContainsAll(tags, keys)
		if JSONTruth {
			var adminLogin entity.AdminLogin
			err = json.Unmarshal(body, &adminLogin)
			if err != nil {
				fmt.Println("body problem")
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			adminLoginResult, err := s.adminStorage.Login(adminLogin)
			fmt.Println(adminLoginResult)

			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			w.WriteHeader(http.StatusOK)
			resp, err := json.Marshal(adminLoginResult)
			_, err = w.Write(resp)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
		} else {
			http.Error(w, "Method not allowed ", http.StatusMethodNotAllowed)
			return
		}
	} else {
		http.Error(w, "Post request required ", http.StatusNotAcceptable)
	}
}

func (s AdminServiceObject) ChangeUserFace(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		err := r.ParseMultipartForm(10 << 20)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		token := r.FormValue("token")
		if token == "" {
			http.Error(w, "Missing 'token' field ", http.StatusBadRequest)
			return
		}

		if isOK, err := s.adminStorage.CheckToken(token); isOK == false {
			w.WriteHeader(200)
			err = json.NewEncoder(w).Encode(entity.CommonResult{IsValid: false, IsTokenValid: false})
			if err != nil {
				fmt.Println(err)
			}
			return
		}

		id := r.FormValue("id")
		if id == "" {
			http.Error(w, "Missing 'id' field ", http.StatusBadRequest)
			return
		}

		file, _, err := r.FormFile("photo")
		if err != nil {
			http.Error(w, "Error retrieving file", http.StatusBadRequest)
			return
		}
		defer func(file multipart.File) {
			err := file.Close()
			if err != nil {
				return
			}
		}(file)
		photo, err := io.ReadAll(file)
		if err != nil {
			http.Error(w, "Error reading the file", http.StatusInternalServerError)
			return
		}

		var changeImage = entity.ChangeImage{
			ID:    id,
			Photo: photo,
		}

		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		commonResult, err := s.userStorage.ChangeUserFace(changeImage)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		resp, err := json.Marshal(commonResult)
		_, err = w.Write(resp)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

	}
}

func (s AdminServiceObject) ChangePassword(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Failed to read request body", http.StatusInternalServerError)
			return
		}

		var data map[string]string
		err = json.Unmarshal(body, &data)
		if err != nil {
			http.Error(w, "Failed to parse body", http.StatusBadRequest)
			return
		}
		fmt.Printf("Received data: %v\n", data)

		if isOK, err := s.adminStorage.CheckToken(data["token"]); isOK == false {
			w.WriteHeader(200)
			err = json.NewEncoder(w).Encode(entity.CommonResult{IsValid: false, IsTokenValid: false})
			if err != nil {
				fmt.Println(err)
			}
			return
		}

		keys := s.GetAllKeys(data)
		tags := s.GetJSONTags(entity.ChangePassword{})
		JSONTruth := s.ContainsAll(tags, keys)
		if JSONTruth {
			var changePassword entity.ChangePassword
			err = json.Unmarshal(body, &changePassword)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			commonResult, err := s.adminStorage.ChangePassword(changePassword)
			fmt.Println(commonResult)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			w.WriteHeader(http.StatusOK)
			resp, err := json.Marshal(commonResult)
			_, err = w.Write(resp)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
		} else {
			http.Error(w, "Method not allowed ", http.StatusMethodNotAllowed)
			return
		}
	}

}

func (s AdminServiceObject) AddUser(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		fmt.Println("adding user")
		err := r.ParseMultipartForm(100 << 20)
		if err != nil {
			fmt.Println(err)
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		token := r.FormValue("token")
		if token == "" {
			http.Error(w, "Missing 'token' field", http.StatusBadRequest)
			return
		}
		if isOK, err := s.adminStorage.CheckToken(token); isOK == false {
			w.WriteHeader(200)
			err = json.NewEncoder(w).Encode(entity.CommonResult{IsValid: false, IsTokenValid: false})
			if err != nil {
				fmt.Println(err)
			}
			return
		}

		id := uuid.New().String()

		//id := r.FormValue("id")
		//if id == "" {
		//	http.Error(w, "Missing 'id' field ", http.StatusBadRequest)
		//	return
		//}

		name := r.FormValue("name")
		if name == "" {
			http.Error(w, "Missing 'name' field ", http.StatusBadRequest)
			return
		}
		surname := r.FormValue("surname")
		if surname == "" {
			http.Error(w, "Missing 'surname' field ", http.StatusBadRequest)
			return
		}
		fathersName := r.FormValue("fathers_name")
		if fathersName == "" {
			http.Error(w, "Missing 'fathers_name' field ", http.StatusBadRequest)
			return
		}
		group := r.FormValue("group")
		if group == "" {
			http.Error(w, "Missing 'group' field ", http.StatusBadRequest)
			return
		}

		file, _, err := r.FormFile("photo")
		if err != nil {
			http.Error(w, "Error retrieving file", http.StatusBadRequest)
			return
		}
		defer func(file multipart.File) {
			err := file.Close()
			if err != nil {
				return
			}
		}(file)
		photo, err := io.ReadAll(file)
		if err != nil {
			http.Error(w, "Error reading the file", http.StatusInternalServerError)
			return
		}

		//err = ioutil.WriteFile("./photo.jpg", photo, 0644)
		//if err != nil {
		//	http.Error(w, "Error reading the file", http.StatusInternalServerError)
		//	return
		//}

		var userView = entity.UserView{
			ID:          id,
			Name:        name,
			Surname:     surname,
			FathersName: fathersName,
			Group:       group,
		}

		var userFull = entity.UserFull{
			UserView: userView,
			Photo:    photo,
		}

		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		commonResult, err := s.userStorage.AddUser(userFull)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		resp, err := json.Marshal(commonResult)
		_, err = w.Write(resp)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

	}

}

func (s AdminServiceObject) DeleteUser(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Failed to read request body", http.StatusInternalServerError)
			return
		}

		var data map[string]string
		err = json.Unmarshal(body, &data)
		if err != nil {
			http.Error(w, "Failed to parse body", http.StatusBadRequest)
			return
		}
		fmt.Printf("Received data: %v\n", data)

		if isOK, err := s.adminStorage.CheckToken(data["token"]); isOK == false {
			w.WriteHeader(200)
			err = json.NewEncoder(w).Encode(entity.CommonResult{IsValid: false, IsTokenValid: false})
			if err != nil {
				fmt.Println(err)
			}
			return
		}

		keys := s.GetAllKeys(data)
		tags := s.GetJSONTags(entity.DeleteUser{})
		JSONTruth := s.ContainsAll(tags, keys)
		if JSONTruth {
			var deleteUser entity.DeleteUser
			err = json.Unmarshal(body, &deleteUser)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			lookDatesResult, err := s.userStorage.DeleteUser(deleteUser)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			w.WriteHeader(http.StatusOK)
			resp, err := json.Marshal(lookDatesResult)
			_, err = w.Write(resp)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
		} else {
			http.Error(w, "Method not allowed ", http.StatusMethodNotAllowed)
			return
		}
	}

}

func (s AdminServiceObject) AddGroup(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Failed to read request body", http.StatusInternalServerError)
			return
		}

		var data map[string]string
		err = json.Unmarshal(body, &data)
		if err != nil {
			http.Error(w, "Failed to parse body", http.StatusBadRequest)
			return
		}
		fmt.Printf("Received data: %v\n", data)

		if isOK, err := s.adminStorage.CheckToken(data["token"]); isOK == false {
			w.WriteHeader(200)
			err = json.NewEncoder(w).Encode(entity.CommonResult{IsValid: false, IsTokenValid: false})
			if err != nil {
				fmt.Println(err)
			}
			return
		}

		keys := s.GetAllKeys(data)
		tags := s.GetJSONTags(entity.AddGroup{})
		JSONTruth := s.ContainsAll(tags, keys)
		if JSONTruth {
			var addGroup entity.AddGroup
			err = json.Unmarshal(body, &addGroup)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			lookDatesResult, err := s.userStorage.AddGroup(addGroup)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			w.WriteHeader(http.StatusOK)
			resp, err := json.Marshal(lookDatesResult)
			_, err = w.Write(resp)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
		} else {
			http.Error(w, "Method not allowed ", http.StatusMethodNotAllowed)
			return
		}
	}

}

func (s AdminServiceObject) DeleteGroup(w http.ResponseWriter, r *http.Request) {
	if r.Method == "POST" {
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Failed to read request body", http.StatusInternalServerError)
			return
		}

		var data map[string]string
		err = json.Unmarshal(body, &data)
		if err != nil {
			http.Error(w, "Failed to parse body", http.StatusBadRequest)
			return
		}

		if isOK, err := s.adminStorage.CheckToken(data["token"]); isOK == false {
			w.WriteHeader(200)
			err = json.NewEncoder(w).Encode(entity.CommonResult{IsValid: false, IsTokenValid: false})
			if err != nil {
				fmt.Println(err)
			}
			return
		}

		fmt.Printf("Received data: %v\n", data)

		keys := s.GetAllKeys(data)
		tags := s.GetJSONTags(entity.DeleteGroup{})
		JSONTruth := s.ContainsAll(tags, keys)
		if JSONTruth {
			var deleteGroup entity.DeleteGroup
			err = json.Unmarshal(body, &deleteGroup)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			deleteGroupResult, err := s.userStorage.DeleteGroup(deleteGroup)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}

			w.WriteHeader(http.StatusOK)
			resp, err := json.Marshal(deleteGroupResult)
			_, err = w.Write(resp)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
		} else {
			http.Error(w, "Method not allowed ", http.StatusMethodNotAllowed)
			return
		}
	}
}

func (s AdminServiceObject) GetAllKeys(m map[string]string) []string {
	keys := make([]string, 0, len(m))
	for key := range m {
		keys = append(keys, key)
	}
	return keys
}

func (s AdminServiceObject) GetJSONTags(c interface{}) []string {
	t := reflect.TypeOf(c)
	if t.Kind() == reflect.Ptr {
		t = t.Elem()
	}
	if t.Kind() != reflect.Struct {
		return nil
	}
	var tags []string
	for i := 0; i < t.NumField(); i++ {
		field := t.Field(i)
		tag := field.Tag.Get("json")
		if tag != "" {
			tags = append(tags, tag)
		}
	}
	return tags

}

func (s AdminServiceObject) ContainsAll(slice1, slice2 []string) bool {
	elements := make(map[string]bool)
	for _, item := range slice2 {
		elements[item] = true
	}
	for _, item := range slice1 {
		if !elements[item] {
			return false
		}
	}
	return true
}
