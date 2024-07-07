package ipcam

import (
	"FaceQ/internal/adapters/db/sqlite/user"
	"FaceQ/internal/domain/Service"
	"context"
	"database/sql"
)

func NewCamService(ctx context.Context, db *sql.DB, camAddress string, PythonRecognizerAddress string, Type string) error {
	camStorageObject, err := user.NewCamStorageObject(db, PythonRecognizerAddress, Type)
	if err != nil {
		return err
	}
	userService, err := Service.NewUserService(camStorageObject)
	if err != nil {
		return err
	}

	for {
		select {
		case <-ctx.Done():
			return nil
		default:
			frame, err := userService.GetFrame(camAddress)
			if err != nil {
				err := ctx.Err()
				if err != nil {
					return err
				}
			}
			recognitionResult, err := userService.Recognize(frame)
			if err != nil {
				err := ctx.Err()
				if err != nil {
					return err
				}
			}
			if recognitionResult.IsOk {
				err := userService.AddChanges(recognitionResult)
				if err != nil {
					err := ctx.Err()
					if err != nil {
						return err
					}
				}
			}
		}

	}

}
