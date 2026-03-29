package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

func main() {
	if len(os.Args) < 3 {
		fmt.Fprintln(os.Stderr, "Usage: ascii-frames <video-path> <width>")
		os.Exit(1)
	}

	videoPath := os.Args[1]
	width := os.Args[2]

	outputDir, err := os.MkdirTemp("", "ascii-frames-")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to create temp directory: %v\n", err)
		os.Exit(1)
	}

	outputPattern := filepath.Join(outputDir, "frame_%04d.png")

	cmd := exec.Command("ffmpeg", "-i", videoPath, outputPattern)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	fmt.Printf("Extracting frames from %s...\n", videoPath)
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "ffmpeg failed: %v\n", err)
		os.Exit(1)
	}

	asciiDir, err := os.MkdirTemp("", "ascii-frames-out-")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to create ascii output directory: %v\n", err)
		os.Exit(1)
	}

	frames, err := filepath.Glob(filepath.Join(outputDir, "frame_*.png"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to list frames: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Converting %d frames to ASCII (width=%s)...\n", len(frames), width)
	for _, frame := range frames {
		baseName := filepath.Base(frame)
		asciiName := baseName[:len(baseName)-len(filepath.Ext(baseName))]
		asciiPath := filepath.Join(asciiDir, asciiName)

		outFile, err := os.Create(asciiPath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Failed to create %s: %v\n", asciiPath, err)
			os.Exit(1)
		}

		cmd := exec.Command("jp2a", "--colors", "--width="+width, frame)
		cmd.Stdout = outFile
		cmd.Stderr = os.Stderr

		if err := cmd.Run(); err != nil {
			outFile.Close()
			fmt.Fprintf(os.Stderr, "jp2a failed on %s: %v\n", frame, err)
			os.Exit(1)
		}
		outFile.Close()
	}

	fmt.Println("Done. ASCII frames saved to", asciiDir)
}
