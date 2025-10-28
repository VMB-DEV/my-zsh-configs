# Bluetooth connect helper
# 
# Just source the file in your .zshrc and use it for easy aliases, for exemple:
# source my-zsh-configs/bluetooth-connection.sh
# alias coearbuds="btconnect [<some-mac-address>]"
# alias discoearbuds="btdisconnect [<some-mac-address>]"



btconnect() {
	MAC_ADDRESS=$1
	if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
		rfkill unblock bluetooth
		sleep 1
	fi
	bluetoothctl connect $MAC_ADDRESS
}

btdisconnect() {
	MAC_ADDRESS=$1
	bluetoothctl disconnect $MAC_ADDRESS
}
