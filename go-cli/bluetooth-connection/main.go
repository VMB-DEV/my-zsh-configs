package main

import (
	"bufio"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

//todo : activate bluetooth if needed

func main() {
	// fzf check
	if _, err := exec.LookPath("fzf"); err != nil {
		panic("fzf is required but not found")
	}

	// get the file path
	configFilePath := os.Getenv("BT_DEVICE_FILE")
	if len(configFilePath) == 0 {
		panic("No BT_DEVICE_FILE env variable defined")
	}

	// read the file
	readFile, err := os.Open(configFilePath)
	if err != nil {
		panic("Can not read " + configFilePath + ": " + err.Error())
	}
	defer func() { _ = readFile.Close() }()

	fileScanner := bufio.NewScanner(readFile)
	fileScanner.Split(bufio.ScanLines)
	var fileLines []string

	for fileScanner.Scan() {
		fileLines = append(fileLines, fileScanner.Text())
	}
	if err := fileScanner.Err(); err != nil {
		panic("Error reading file " + configFilePath)
	}

	// parse lines into DeviceData
	var devices DeviceList
	for _, line := range fileLines {
		if deviceData, err := parseLine(line); err == nil {
			devices = append(devices, deviceData)
		}
	}
	if len(devices) == 0 {
		panic("No valid devices found in config file")
	}

	// build display lines for fzf (name\tdescription)
	var displayLines []string
	for _, d := range devices {
		displayLines = append(displayLines, d.name+"\t"+d.description)
	}

	// run fzf for selection
	deviceSelectionCmd := exec.Command("fzf",
		"--height=~15",            // max 15 lines, shrinks if fewer items
		"--layout=reverse",        // input prompt at top, results below
		"--border",                // draw a box around the fzf interface
		"--delimiter=\t",          // split input lines by tab character
		"--with-nth=1",            // display only field 1 (device name) in the list
		"--preview=echo {2}",      // show field 2 (description) in preview pane
		"--preview-window=down:1", // preview pane at bottom, 1 line tall
		"--prompt=Device ➤ ",      // custom prompt text
	)
	deviceSelectionCmd.Stdin = strings.NewReader(strings.Join(displayLines, "\n"))
	deviceSelectionCmd.Stderr = os.Stderr
	deviceNameSelection, err := deviceSelectionCmd.Output()
	if err != nil {
		fmt.Println("No device selected\t(¬_¬)")
		return
	}

	selectedName := strings.TrimSpace(string(deviceNameSelection))

	// extract device name (first part before tab)
	deviceName := strings.Split(selectedName, "\t")[0]
	selectedDeviceData, err := devices.findElement(deviceName)
	if err != nil {
		panic("Error trying to retrieve data for the device : " + deviceName)
	}

	// run fzf to select the action to apply on the device
	coDiscoChoices := []string{"connect", "disconnect"}
	coDiscoCmd := exec.Command("fzf",
		"--height=~10",
		"--layout=reverse",
		"--border",
		"--prompt= ("+selectedDeviceData.mac+") - "+selectedDeviceData.name+" ➤ ",
	)
	coDiscoCmd.Stdin = strings.NewReader(strings.Join(coDiscoChoices, "\n"))
	coDiscoCmd.Stderr = os.Stderr
	coDiscoCmdSelection, err := coDiscoCmd.Output()
	if err != nil {
		fmt.Println("You need to select either " + strings.Join(coDiscoChoices, "or ") + "\t(¬_¬)")
		return
	}
	action := strings.TrimSpace(string(coDiscoCmdSelection))

	// action command
	output, err := exec.Command("bluetoothctl", action, selectedDeviceData.mac).CombinedOutput()
	if err != nil {
		fmt.Println("Error:", err)
	}
	if len(output) > 0 {
		fmt.Println(string(output))
	}
}

type DeviceData struct {
	mac         string
	name        string
	description string
}

// NewDeviceData creates a DeviceData from parsed values
func newDeviceData(mac, name, description string) (DeviceData, error) {
	if len(name) == 0 || len(mac) == 0 {
		return DeviceData{}, errors.New("missing name or mac: name=" + name + " mac=" + mac)
	}
	return DeviceData{
		mac:         mac,
		name:        name,
		description: description,
	}, nil
}

// ParseLine parses a pipe-separated line into DeviceData
func parseLine(line string) (DeviceData, error) {
	split := strings.Split(line, "|")
	if len(split) < 2 {
		return DeviceData{}, errors.New("malformed line: " + line)
	}
	mac := split[0]
	name := split[1]
	description := ""
	if len(split) >= 3 {
		description = split[2]
	}
	return newDeviceData(mac, name, description)
}

type DeviceList []DeviceData

func (list DeviceList) findElement(name string) (DeviceData, error) {
	for _, deviceData := range list {
		if deviceData.name == name {
			return deviceData, nil
		}
	}
	return DeviceData{}, errors.New("Could not find the element named " + name)
}
