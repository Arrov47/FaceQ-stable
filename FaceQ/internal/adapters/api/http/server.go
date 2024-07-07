package http

import (
	"FaceQ/internal/adapters/db/sqlite/admin"
	"FaceQ/internal/adapters/db/sqlite/user"
	"FaceQ/internal/domain/Service"
	"database/sql"
	"fmt"
	"net/http"
)

func NewServer(udb *sql.DB, adb *sql.DB, port string, host string) error {

	UserStorage, err := user.NewStorageObject(udb)
	if err != nil {
		fmt.Println(err)
		return err
	}

	AdminStorage, err := admin.NewStorageObject(adb)
	if err != nil {
		fmt.Println(err)
		return err
	}

	AdminService, err := Service.NewAdminService(UserStorage, AdminStorage)
	if err != nil {
		fmt.Println(err)
		return err
	}
	mux := http.NewServeMux()
	mux.HandleFunc("/addUser", AdminService.AddUser)
	mux.HandleFunc("/addGroup", AdminService.AddGroup)
	mux.HandleFunc("/getDate", AdminService.LookDates)
	mux.HandleFunc("/getGroups", AdminService.GetGroups)
	mux.HandleFunc("/checkPassword", AdminService.Login)
	mux.HandleFunc("/getContact", AdminService.GetContact)
	mux.HandleFunc("/checkToken", AdminService.CheckToken)
	mux.HandleFunc("/deleteUser", AdminService.DeleteUser)
	mux.HandleFunc("/deleteGroup", AdminService.DeleteGroup)
	mux.HandleFunc("/changePassword", AdminService.ChangePassword)
	mux.HandleFunc("/changeUserFace", AdminService.ChangeUserFace)
	//mux.HandleFunc("/doorCommand", AdminService.doorCommand)

	fmt.Println("Server started at " + host + ":" + port)
	err = http.ListenAndServe(host+":"+port, mux)
	return err

}
