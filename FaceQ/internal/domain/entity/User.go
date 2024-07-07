package entity

type UserFull struct {
	UserView `json:"user_view"`
	Photo    []byte `json:"photo"`
}

type ChangeImage struct {
	ID    string `json:"id"`
	Photo []byte `json:"photo"`
}

type Person struct {
	Image []byte `json:"image"`
	BLOB  []byte `json:"blob"`
}

type ConvertToBLOB struct {
	Image []byte `json:"image,omitempty"`
}

type UserView struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Surname     string `json:"surname"`
	FathersName string `json:"fathers_name"`
	Group       string `json:"group"`
}

type Action struct {
	Type string `json:"type,omitempty"`
	Time string `json:"time,omitempty"`
}

type Logs struct {
	Log map[string]interface{}
}

type Log struct {
	Log []Action
}
