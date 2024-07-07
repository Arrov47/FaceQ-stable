package entity

type Admin struct {
	Login    string `json:"login"`
	Password string `json:"password"`
	Token    string `json:"token"`
}

type AdminLogin struct {
	Login    string `json:"login"`
	Password string `json:"password"`
}

type AdminLoginResult struct {
	Token string `json:"token"`
}

type CommonResult struct {
	IsValid      bool `json:"is_valid"`
	IsTokenValid bool `json:"is_token_valid"`
}

type LookDates struct {
	Token string `json:"token"`
	Date  string `json:"date"`
	Group string `json:"group"`
}

type ChangePassword struct {
	Token       string `json:"token"`
	OldPassword string `json:"old_password"`
	NewPassword string `json:"new_password"`
}
type CheckToken struct {
	Token string `json:"token"`
}

type AddUser struct {
	Token    string `json:"token"`
	UserFull `json:"user_full"`
}

type DeleteUser struct {
	Token string `json:"token,"`
	ID    string `json:"id"`
}

type AddGroup struct {
	Token     string `json:"token"`
	GroupName string `json:"group_name"`
}

type DeleteGroup struct {
	Token     string `json:"token"`
	GroupName string `json:"group_name"`
}

type GetGroups struct {
	Token string `json:"token"`
}

type GetGroupsResult struct {
	Groups       []string `json:"groups"`
	IsValid      bool     `json:"is_valid"`
	IsTokenValid bool     `json:"is_token_valid"`
}

type LookDatesResult struct {
	Data         [][]interface{} `json:"data"`
	IsValid      bool            `json:"is_valid"`
	IsTokenValid bool            `json:"is_token_valid"`
}
