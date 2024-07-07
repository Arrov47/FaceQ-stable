package entity

type Frame struct {
	ImageData []byte `json:"image_data"`
	QRCode    string `json:"qr_code"`
}

type RecognitionResult struct {
	IsOk   bool   `json:"is_ok"`
	QRCode string `json:"qr_code"`
}
