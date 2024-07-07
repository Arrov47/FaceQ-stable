package GetIP

import (
	"fmt"
	"net"
)

func GetIp() ([]string, error) {
	var listt []string
	interfaces, err := net.Interfaces()
	if err != nil {
		return listt, err
	}

	for _, interf := range interfaces {
		if interf.Flags&net.FlagUp == 0 {
			continue // interface is down
		}
		if interf.Flags&net.FlagLoopback != 0 {
			continue // interface is loopback
		}

		addrs, err := interf.Addrs()
		if err != nil {
			return listt, err
		}

		for _, addr := range addrs {
			ipNet, ok := addr.(*net.IPNet)
			if !ok {
				continue
			}
			if ipNet.IP.To4() != nil {
				ipsi := ipNet.IP.String()
				listt = append(listt, ipsi)
			}
		}
	}

	if len(listt) == 0 {
		return listt, fmt.Errorf("Wi-Fi IP address not found")
	}

	return listt, nil
}
