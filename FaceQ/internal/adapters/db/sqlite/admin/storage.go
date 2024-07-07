package admin

import (
	"FaceQ/internal/domain/entity"
	"database/sql"
	"fmt"
	"github.com/google/uuid"
)

type Storage interface {
	Login(admin entity.AdminLogin) (entity.AdminLoginResult, error)
	ChangePassword(password entity.ChangePassword) (entity.CommonResult, error)
	CheckToken(token string) (bool, error)
}

type StorageObject struct {
	db *sql.DB
}

func NewStorageObject(db *sql.DB) (StorageObject, error) {
	return StorageObject{
		db: db,
	}, nil
}

func (s StorageObject) Login(admin entity.AdminLogin) (entity.AdminLoginResult, error) {
	passwordSQL, err := s.CheckPasswordSQL(admin.Password, admin.Login)
	if !passwordSQL {
		return entity.AdminLoginResult{Token: ""}, nil
	}
	if err != nil {
		fmt.Println("CheckPass prob")
		return entity.AdminLoginResult{Token: ""}, err
	}

	newToken := uuid.New().String()

	_, err = s.db.Exec("UPDATE admin SET token=? WHERE login=?", newToken, "admin")
	if err != nil {
		fmt.Println("Problem with updating token in admin")
		fmt.Println(err)
		return entity.AdminLoginResult{Token: ""}, err
	}

	if passwordSQL {
		return entity.AdminLoginResult{
			Token: newToken,
		}, nil
	}
	return entity.AdminLoginResult{Token: ""}, err
}

func (s StorageObject) CheckToken(token string) (bool, error) {
	var exists int
	err := s.db.QueryRow("SELECT 1 FROM admin WHERE token=? ", token).Scan(&exists)
	if err != nil {
		return false, err
	}

	return true, nil
}

func (s StorageObject) ChangePassword(password entity.ChangePassword) (entity.CommonResult, error) {
	passwordSQL, err := s.CheckPasswordSQL(password.OldPassword, "admin")
	if !passwordSQL {
		return entity.CommonResult{IsValid: false}, nil
	}
	if err != nil {
		return entity.CommonResult{}, err
	}

	err = s.ChangePasswordSQL(password.NewPassword)
	if err != nil {
		return entity.CommonResult{}, err
	}
	return entity.CommonResult{
		IsValid: passwordSQL,
	}, nil
}

func (s StorageObject) CreateAdminTable() error {
	tableCreateSQL :=
		`CREATE TABLE IF NOT EXISTS admin (
	    id INTEGER NOT NULL	PRIMARY KEY AUTOINCREMENT,
	    login TEXT,
	    password TEXT,
	    token TEXT
        )`

	_, err := s.db.Exec(tableCreateSQL)
	if err != nil {
		return err
	}

	insertDefaultAdmin := "INSERT INTO admin (login, password, token) VALUES (?, ?, ?)"
	_, err = s.db.Exec(insertDefaultAdmin, "admin", "admin", "")
	if err != nil {
		return err
	}

	return nil
}

func (s StorageObject) ChangePasswordSQL(newPassword string) error {
	changePasswordSQL := "UPDATE admin SET password=? WHERE login=?"
	_, err := s.db.Exec(changePasswordSQL, newPassword, "admin")
	if err != nil {
		err = s.CreateAdminTable()
		if err != nil {
			return err
		}
		err := s.ChangePasswordSQL(newPassword)
		if err != nil {
			return err
		}
		return err
	}
	return nil
}

func (s StorageObject) CheckPasswordSQL(password, login string) (bool, error) {
	changePasswordSQL := "SELECT * FROM admin WHERE login=?"
	rows, err := s.db.Query(changePasswordSQL, login)
	defer func(rows *sql.Rows) {
		err := rows.Close()
		if err != nil {

		}
	}(rows)
	if err != nil {
		fmt.Println("There is no admin table")
		err := s.CreateAdminTable()
		if err != nil {
			return false, err
		}
		changePassword, err := s.CheckPasswordSQL(password, login)
		if err != nil {
			return false, err
		}
		return changePassword, nil
	}
	rows.Next()
	var truePassword, name, token string
	var id int
	err = rows.Scan(&id, &name, &truePassword, &token)
	if err != nil {
		fmt.Println(err)
		return false, err

	}

	if truePassword == password {
		fmt.Println("Password is true")
		return true, nil
	}
	return false, fmt.Errorf("-------------->can't check password")
}
