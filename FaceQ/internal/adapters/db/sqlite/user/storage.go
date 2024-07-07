package user

import (
	"FaceQ/internal/domain/entity"
	"bytes"
	"database/sql"
	"encoding/json"
	"fmt"
	"github.com/makiuchi-d/gozxing"
	"github.com/makiuchi-d/gozxing/qrcode"
	"gocv.io/x/gocv"
	"image"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

type Storage interface {
	LookDates(dates entity.LookDates) (entity.LookDatesResult, error)
	AddUser(full entity.UserFull) (entity.CommonResult, error)
	DeleteUser(user entity.DeleteUser) (entity.CommonResult, error)
	AddGroup(group entity.AddGroup) (entity.CommonResult, error)
	GetGroups() (entity.GetGroupsResult, error)
	DeleteGroup(group entity.DeleteGroup) (entity.CommonResult, error)
	ChangeUserFace(faceId entity.ChangeImage) (entity.CommonResult, error)
	CreateTableInUsers() error
}

type CamStorage interface {
	GetFrame(camAddress string) (entity.Frame, error)
	Recognize(frame entity.Frame) (entity.RecognitionResult, error)
	AddChanges(result entity.RecognitionResult) error
}

type CamStorageObject struct {
	Type                       string
	PythonRecognizerAPIAddress string
	db                         *sql.DB
}

func NewCamStorageObject(db *sql.DB, PythonRecognizerAPIAddress string, Type string) (CamStorageObject, error) {
	return CamStorageObject{
		db:                         db,
		PythonRecognizerAPIAddress: PythonRecognizerAPIAddress,
		Type:                       Type,
	}, nil
}

func (p CamStorageObject) GetFrame(camAddress string) (entity.Frame, error) {
	webcam, err := gocv.OpenVideoCapture(camAddress)
	defer func(webcam *gocv.VideoCapture) {
		err := webcam.Close()
		if err != nil {
			log.Fatalf("Error while closing video capture %v", err)
		}
	}(webcam)
	if err != nil {
		return entity.Frame{}, err
	}
	img := gocv.NewMat()
	defer func(img *gocv.Mat) {
		err := img.Close()
		if err != nil {
			fmt.Printf("\n Error closing the image: %v \n", err)
		}
	}(&img)
	//window := gocv.NewWindow("QR Code Scanner " + string(rune(num)))
	// Create a QR Code reader
	reader := qrcode.NewQRCodeReader()
	var goImg image.Image
	var bitmap *gozxing.BinaryBitmap
	var QRCode *gozxing.Result

	for {

		if ok := webcam.Read(&img); !ok {
			log.Println("Error reading from webcam")
			continue
		}

		if img.Empty() {
			continue
		}

		// Capture a frame
		//window.IMShow(img)
		//window.WaitKey(1)

		// Convert the image matrix to a Go image
		goImg, err = img.ToImage()
		if err != nil {
			log.Printf("Error converting Mat to image: %v", err)
		}

		//Decode the Qr code from Go image
		bitmap, _ = gozxing.NewBinaryBitmapFromImage(goImg)
		QRCode, err = reader.Decode(bitmap, nil)
		if err != nil {
			continue
		}
		fmt.Printf("QR Code detected: %s \n", QRCode.String())
		var exists int
		err = p.db.QueryRow("SELECT COUNT(1) FROM users WHERE id=? ", exists).Scan(&exists)
		if err == nil || exists == 1 {
			fmt.Println("exists: ", exists)
			imgByte, err := gocv.IMEncode(".jpg", img)
			if err != nil {
				continue
			}
			return entity.Frame{ImageData: imgByte.GetBytes(), QRCode: QRCode.String()}, nil
		}
		fmt.Println(exists)
		fmt.Println(err)
		continue

	}
}

func (p CamStorageObject) Recognize(frame entity.Frame) (entity.RecognitionResult, error) {

	fmt.Println("recognize started")
	// Connect to RTSP stream
	rows, err := p.db.Query("SELECT faceId from users WHERE id=?", frame.QRCode)
	if err != nil {
		return entity.RecognitionResult{IsOk: false}, err
	}
	var knownBlob []byte
	if rows.Next() {
		err = rows.Scan(&knownBlob)
		if err != nil {
			return entity.RecognitionResult{IsOk: false}, err
		}

	}
	person := entity.Person{Image: frame.ImageData, BLOB: knownBlob}

	//Кодирование данных в JSON
	jsonData, err := json.Marshal(person)
	if err != nil {
		fmt.Printf("Ошибка при кодировании JSON: %v \n", err)
	}
	fmt.Println("json yasaldy")

	// Создание POST запроса
	req, err := http.NewRequest("POST", p.PythonRecognizerAPIAddress, bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Printf("Ошибка при создании запроса: %v \n", err)
	}

	// Установка заголовков
	req.Header.Set("Content-Type", "application/json")

	// Отправка запроса
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return entity.RecognitionResult{IsOk: false}, err
	}
	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {
			fmt.Println(err)
		}
	}(resp.Body)
	// Чтение ответа сервера
	var result map[string]bool
	err = json.NewDecoder(resp.Body).Decode(&result)
	if err != nil {
		fmt.Printf("err in decoder recognizer: %v \n", err)
		return entity.RecognitionResult{IsOk: false}, err
	}

	if result["is_valid"] && !result["is_empty"] {
		fmt.Println("success in recognize")
		return entity.RecognitionResult{QRCode: frame.QRCode, IsOk: true}, nil
	}
	fmt.Println("Error in recognize")
	return entity.RecognitionResult{IsOk: false}, fmt.Errorf("Result from recognizer false or not supported ") //// QRCode equals to id of user
}

func NewStorageObject(db *sql.DB) (StorageObject, error) {
	return StorageObject{
		db: db,
	}, nil
}

type StorageObject struct {
	db *sql.DB
}

func (s StorageObject) LookDates(dates entity.LookDates) (entity.LookDatesResult, error) {
	data, err := s.GetDateReport(dates.Date, dates.Group)
	if err != nil {
		return entity.LookDatesResult{Data: [][]interface{}{}, IsTokenValid: true, IsValid: false}, err
	}
	return entity.LookDatesResult{
		Data:         data,
		IsTokenValid: true,
		IsValid:      true,
	}, nil
}

func (s StorageObject) GetGroups() (entity.GetGroupsResult, error) {
	var data map[string][]string
	Groups, err := ioutil.ReadFile("./groups.json")
	err = json.Unmarshal(Groups, &data)
	if err != nil {
		return entity.GetGroupsResult{Groups: data["groups"], IsTokenValid: true, IsValid: false}, err
	}
	return entity.GetGroupsResult{
		Groups:       data["groups"],
		IsTokenValid: true,
		IsValid:      true,
	}, nil
}

func (s StorageObject) ChangeUserFace(changeImage entity.ChangeImage) (entity.CommonResult, error) {
	changeUserFaceSQL := "UPDATE users SET faceId=? WHERE id=?"
	var blob []byte
	blob, err := s.ConvertToBlob(changeImage.Photo)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}
	_, err = s.db.Exec(changeUserFaceSQL, blob, changeImage.ID)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}
	return entity.CommonResult{IsValid: true, IsTokenValid: true}, nil
}

func (s StorageObject) AddUser(full entity.UserFull) (entity.CommonResult, error) {

	addUserSQL := `INSERT INTO users (id, name, surname, fathers_name, group_, faceId) VALUES (?, ?, ?, ?, ?, ?)`
	blob, err := s.ConvertToBlob(full.Photo)
	if err != nil {
		fmt.Println(err)
	}
	_, err = s.db.Exec(addUserSQL, full.ID, full.Name, full.Surname, full.FathersName, full.Group, blob)
	if err != nil {
		err = s.CreateTableInUsers()
		if err != nil {
			return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
		}
		_, err = s.db.Exec(addUserSQL, full.ID, full.Name, full.Surname, full.FathersName, full.Group, blob)
		if err != nil {
			return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
		}
	}
	fmt.Println("User added successfully ")
	return entity.CommonResult{IsValid: true, IsTokenValid: true}, nil
}

func (s StorageObject) ConvertToBlob(photo []byte) ([]byte, error) {
	url := "http://127.0.0.1:2363/convert_image_to_the_blob"

	//Создание данных для отправки
	person := entity.ConvertToBLOB{
		Image: photo,
	}

	//Кодирование данных в JSON
	jsonData, err := json.Marshal(person)
	if err != nil {
		return nil, err
	}

	// Создание POST запроса
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {

		return nil, err
	}

	// Установка заголовков
	req.Header.Set("Content-Type", "application/json")

	// Отправка запроса
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("osibka ine ")
		return nil, err
	}
	defer func(Body io.ReadCloser) {
		_ = Body.Close()
	}(resp.Body)

	// Чтение ответа сервера
	var result map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&result)
	if err != nil {
		return nil, err
	}
	if result["is_valid"].(bool) {
		return []byte(result["blob"].(string)), nil
	} else {
		return nil, fmt.Errorf("There is no user in image ")
	}
}

func (s StorageObject) DeleteUser(user entity.DeleteUser) (entity.CommonResult, error) {
	deleteUserSQL := `DELETE * FROM users WHERE id=?`

	_, err := s.db.Exec(deleteUserSQL, user.ID)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}
	return entity.CommonResult{IsValid: true, IsTokenValid: true}, nil
}

//goland:noinspection ALL
func (s StorageObject) AddGroup(group entity.AddGroup) (entity.CommonResult, error) {
	IsOk, err := s.DoesGroupExist(group.GroupName)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}
	if IsOk {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}

	filePath := "groups.json"

	file, err := ioutil.ReadFile(filePath)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}

	var groups map[string][]string
	err = json.Unmarshal(file, &groups)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}

	newGroupList := append(groups["groups"], group.GroupName)
	groups["groups"] = newGroupList
	newGroups, err := json.Marshal(groups)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}

	err = ioutil.WriteFile(filePath, newGroups, 0644)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}

	return entity.CommonResult{IsValid: true, IsTokenValid: true}, nil
}

//goland:noinspection GoDeprecation,GoDeprecation
func (s StorageObject) DeleteGroup(group entity.DeleteGroup) (entity.CommonResult, error) {
	IsOk, err := s.DoesGroupExist(group.GroupName)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}
	if !IsOk {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}

	filePath := "groups.json"

	file, err := ioutil.ReadFile(filePath)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}

	var groups map[string][]string
	err = json.Unmarshal(file, &groups)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}

	var newGroupList []string

	for _, value := range groups["groups"] {
		if value == group.GroupName {
			continue
		}
		newGroupList = append(newGroupList, value)
	}

	groups["groups"] = newGroupList

	newGroups, err := json.Marshal(groups)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}

	err = ioutil.WriteFile(filePath, newGroups, 0644)
	if err != nil {
		return entity.CommonResult{IsValid: false, IsTokenValid: true}, err
	}

	return entity.CommonResult{IsValid: true, IsTokenValid: true}, nil
}

func (s StorageObject) CreateTableInUsers() error {
	createTableUsers :=
		`CREATE TABLE IF NOT EXISTS users (    
    	id TEXT,
	    name TEXT,
	    surname TEXT,
	    fathers_name TEXT,
	    group_ TEXT,
	    faceId BLOB
        )`
	createTableLogs :=
		`CREATE TABLE IF NOT EXISTS logs (
    	id TEXT,
    	name TEXT,
   	 	surname TEXT,
   	 	fathers_name TEXT,
    	group_ TEXT,
    	date TEXT,
	    log BLOB
		)`

	if _, err := s.db.Exec(createTableUsers); err != nil {
		fmt.Println(err)
	}
	if _, err := s.db.Exec(createTableLogs); err != nil {
		fmt.Println(err)
	}
	return nil

}

func (p CamStorageObject) CreateTableInUsers() error {
	createTableUsers :=
		`CREATE TABLE IF NOT EXISTS users (    id TEXT,
	    name TEXT,
	    surname TEXT,
	    fathers_name TEXT,
	    group_ TEXT,
	    faceId BLOB
        )`
	createTableLogs :=
		`CREATE TABLE IF NOT EXISTS logs (    id TEXT,
	    name TEXT,
	    surname TEXT,
	    fathers_name TEXT,
	    group_ TEXT,
	    date TEXT,
	    log BLOB
)`

	if _, err := p.db.Exec(createTableUsers); err != nil {
		fmt.Println(err)
	}
	if _, err := p.db.Exec(createTableLogs); err != nil {
		fmt.Println(err)
	}
	return nil

}

func (s StorageObject) GetDateReport(date, group string) ([][]interface{}, error) {

	var BigData [][]interface{}

	rows, err := s.db.Query("SELECT * FROM logs WHERE date=? AND group_=?", date, group)
	if err != nil {
		return nil, err
	}

	for rows.Next() {
		var userActionData []interface{}
		var (
			id, name, surname, fathersName, group_, date_ string
		)
		var logg []byte
		var logDecoded []interface{}
		err = rows.Scan(&id, &name, &surname, &fathersName, &group_, &date_, &logg)
		if err != nil {
			return nil, err
		}

		err = json.Unmarshal(logg, &logDecoded)
		if err != nil {
			return nil, err
		}
		userActionData = append(userActionData, id, name, surname, fathersName, group_, logDecoded)
		fmt.Println(userActionData)
		BigData = append(BigData, userActionData)
	}
	func(rows *sql.Rows) {
		err = rows.Close()
		if err != nil {
			fmt.Println(err)
		}
	}(rows)
	fmt.Println(BigData)
	return BigData, nil
}

//goland:noinspection GoDeprecation
func (s StorageObject) DoesGroupExist(group string) (bool, error) {
	filePath := "groups.json"

	file, err := ioutil.ReadFile(filePath)
	if err != nil {

		return false, err
	}

	var groups map[string][]string
	err = json.Unmarshal(file, &groups)
	if err != nil {
		return false, err
	}
	for _, str := range groups["groups"] {
		if str == group {
			return true, nil
		}
	}
	return false, nil
}

func (p CamStorageObject) GetLog(id string) ([]entity.Action, error) {
	date := time.Now().Format(time.DateOnly)

	addChangeSQL := `SELECT log FROM logs WHERE date=? AND id=?`
	rows, err := p.db.Query(addChangeSQL, date, id)
	if err != nil {
		return nil, err
	}
	defer func(rows *sql.Rows) {
		err := rows.Close()
		if err != nil {
			fmt.Println(err)
		}
	}(rows)
	var logByte []byte
	var logs []entity.Action
	if rows.Next() {
		err := rows.Scan(&logByte)
		if err != nil {
			return nil, err
		}
	} else {
		return nil, err
	}
	err = json.Unmarshal(logByte, &logs)
	if err != nil {
		return nil, err
	}
	return logs, nil
}

func (p CamStorageObject) AddActions(id string, actions []entity.Action) error {
	date := time.Now().Format(time.DateOnly)
	timeOfAction := time.Now().Format(time.TimeOnly)[:5]
	actions = append(actions, entity.Action{Time: timeOfAction, Type: p.Type})
	actionsByte, err := json.Marshal(actions)
	if err != nil {
		return err
	}
	addChangeSQL := `UPDATE logs SET log=? WHERE id=? AND date=?`
	_, err = p.db.Exec(addChangeSQL, actionsByte, id, date)
	if err != nil {
		return err
	}
	return nil
}

func (p CamStorageObject) CreateAndAddActions(id string) error {
	date := time.Now().Format(time.DateOnly)
	timeOfAction := time.Now().Format(time.TimeOnly)[:5]
	addChangeSQL1 := `SELECT name, surname, fathers_name, group_ FROM users WHERE id=?`
	rows, err := p.db.Query(addChangeSQL1, id)
	if err != nil {
		return err
	}

	var name, surname, fathersName, group string
	if rows.Next() {
		err := rows.Scan(&name, &surname, &fathersName, &group)
		if err != nil {
			return err
		}
	}
	err = rows.Close()
	if err != nil {
		return err
	}
	var data []entity.Action
	var logg = append(data, entity.Action{Time: timeOfAction, Type: p.Type})
	datas, err := json.Marshal(logg)
	if err != nil {
		return err
	}
	fmt.Println(id, name, surname, fathersName, group, date, datas)
	addChangeSQL := "INSERT INTO logs (id, name, surname, fathers_name, group_, date, log) VALUES (?,?,?,?,?,?,?);"
	_, err = p.db.Exec(addChangeSQL, id, name, surname, fathersName, group, date, datas)
	if err != nil {
		fmt.Println(err)
		return err
	}
	return err
}

func (p CamStorageObject) AddChanges(result entity.RecognitionResult) error {
	getLog, err := p.GetLog(result.QRCode)
	fmt.Println(getLog)
	if err != nil || len(getLog) == 0 {
		fmt.Println(err)
		return p.CreateAndAddActions(result.QRCode)
	}
	fmt.Println()
	err = p.AddActions(result.QRCode, getLog)
	if err != nil {
		fmt.Println(err)
		return err
	}
	fmt.Println("boldy oydyan")
	return nil
}
