package Service

import (
	"FaceQ/internal/adapters/db/sqlite/user"
	"FaceQ/internal/domain/entity"
)

type UserServiceCams interface {
	GetFrameWithQRCode(camAddress string) (entity.Frame, error)
	RecognizeFaceInFrame(frame entity.Frame) (entity.RecognitionResult, error)
	AddRecognitionResult(result entity.RecognitionResult) error
}

type UserServiceObject struct {
	userCamStorage user.CamStorage
}

func NewUserService(userCamStorage user.CamStorageObject) (UserServiceObject, error) {
	return UserServiceObject{
		userCamStorage: userCamStorage,
	}, nil
}

func (o UserServiceObject) GetFrame(camAddress string) (entity.Frame, error) {
	return o.userCamStorage.GetFrame(camAddress)
}

func (o UserServiceObject) Recognize(frame entity.Frame) (entity.RecognitionResult, error) {
	return o.userCamStorage.Recognize(frame)
}

func (o UserServiceObject) AddChanges(result entity.RecognitionResult) error {
	return o.userCamStorage.AddChanges(result)
}
