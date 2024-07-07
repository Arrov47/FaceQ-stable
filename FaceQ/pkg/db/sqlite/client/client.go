package client

import (
	"database/sql"
	"fmt"
	_ "github.com/mattn/go-sqlite3"
	"time"
)

func InitDB(DBPath string, DBName string) (*sql.DB, error) {
	ConnectionStr := DBPath + DBName
	for i := 0; i < 10; i++ {
		fmt.Println(ConnectionStr)
		DB, err := sql.Open("sqlite3", ConnectionStr)
		if err == nil {
			return DB, err
		}
		fmt.Printf("Trying to reconnect %d \n", i)
		time.Sleep(time.Second * 3)
	}

	return nil, fmt.Errorf(" \n Cannot reconnect to DB !!!\n ")

}

func GetDB(DbPath string, DbName string) (*sql.DB, error) {
	DB, err := InitDB(DbPath, DbName)
	if err != nil {
		return nil, fmt.Errorf("cannot connect to db")
	}
	return DB, nil
}
