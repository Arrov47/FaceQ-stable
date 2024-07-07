package main

import (
	"FaceQ/internal/adapters/api/http"
	"FaceQ/internal/adapters/api/ipcam"
	"FaceQ/pkg/Scripts/CheckGroupsJSON"
	"FaceQ/pkg/Scripts/CreateQRCodeImage"
	"FaceQ/pkg/Scripts/GetDesktopAddress"
	"FaceQ/pkg/db/sqlite/client"
	"FaceQ/pkg/wlan/GetIP"
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"os/exec"
)

var userDB *sql.DB
var adminDB *sql.DB

func main() {
	fmt.Println("program started")
	errCh := make(chan error)

	err := CheckGroupsJSON.CheckGroups()
	if err != nil {
		log.Fatalf(err.Error())
		return
	}

	ip, err := GetIP.GetIp()
	if err != nil {
		log.Fatalf(err.Error())
		return
	}

	go func(errCh chan error) {
		command := exec.Command("./recognizer.exe")
		err := command.Start()
		if err != nil {
			errCh <- err
			return
		}
		select {
		case err := <-errCh:
			fmt.Println(err)
			_ = command.Cancel()
		}
	}(errCh)
	fmt.Println("recognizer started")

	PythonRecognizerAPIAddress := "http://127.0.0.1:2363/compare_faces"
	Cam1Address := "" //"rtsp://192.168.100.13:8554/1"
	//Cam1Address := "http://61.k,,,,lo211.241.239/nphMotionJpeg?Resolution=320x240&Quality=Standard"
	//Cam1Address := "http://webcam.mchcares.com/mjpg/video.mjpg?timestamp=1566232173730"
	Cam2Address := "rtsp://192.168.100.13:8554/cam2"
	Port := "5243"
	Host := ip[0]
	QRCodeFileName := "FaceQR.png"

	pathToSaveGetDesktopAddress, err := GetDesktopAddress.GetDesktopAddress()
	if err != nil {
		log.Fatal(err)
	}
	err = CreateQRCodeImage.CreateQRCodeImage(pathToSaveGetDesktopAddress, Host+":"+Port, QRCodeFileName)
	if err != nil {
		log.Fatal(err)
	}

	userDB, err = client.GetDB("./", "users.db")
	if err != nil {
		log.Fatal(err)
	}
	defer func(userDB *sql.DB) {
		err := userDB.Close()
		if err != nil {
			fmt.Println(err)
		}
	}(userDB)

	adminDB, err = client.GetDB("./", "admin.db")
	if err != nil {
		log.Fatal(err)
	}
	defer func(adminDB *sql.DB) {
		err := adminDB.Close()
		if err != nil {
			fmt.Println(err)
		}
	}(adminDB)

	fmt.Println("All db created successfully ")

	ctx, cancel := context.WithCancel(context.Background())

	go func() {
		err := http.NewServer(userDB, adminDB, Port, Host)
		fmt.Println("error 1")
		if err != nil {
			errCh <- err
			log.Fatal(err)
		}
	}()

	go func() {
		err := ipcam.NewCamService(ctx, userDB, Cam1Address, PythonRecognizerAPIAddress, "Girdi")
		fmt.Println("error 2")
		if err != nil {
			errCh <- err
			log.Fatal(err)
		}
	}()

	go func() {
		err := ipcam.NewCamService(ctx, userDB, Cam2Address, PythonRecognizerAPIAddress, "Çykdy")
		if err != nil {
			errCh <- err
			log.Fatal(err)
		}
	}()

	fmt.Println("hmm sen goyberdin")
	select {
	case err := <-errCh:
		fmt.Println(err)
		cancel()
		os.Exit(1)
	}
}
