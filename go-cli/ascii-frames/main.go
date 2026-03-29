package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func fatal(msg string, err error) {
	fmt.Fprintf(os.Stderr, "%s: %v\n", msg, err)
	os.Exit(1)
}

func mkTemp(prefix string) string {
	dir, err := os.MkdirTemp("", prefix)
	if err != nil {
		fatal("Failed to create temp directory", err)
	}
	return dir
}

func extractFrames(videoPath, outputDir string) {
	pattern := filepath.Join(outputDir, "frame_%04d.png")
	cmd := exec.Command("ffmpeg", "-i", videoPath, pattern)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	fmt.Printf("Extracting frames from %s...\n", videoPath)
	if err := cmd.Run(); err != nil {
		fatal("ffmpeg failed", err)
	}
}

func convertToAscii(framesDir, asciiDir, width string) {
	frames, err := filepath.Glob(filepath.Join(framesDir, "frame_*.png"))
	if err != nil {
		fatal("Failed to list frames", err)
	}

	fmt.Printf("Converting %d frames to ASCII (width=%s)...\n", len(frames), width)
	for _, frame := range frames {
		convertFrame(frame, asciiDir, width)
	}
}

func convertFrame(frame, asciiDir, width string) {
	name := strings.TrimSuffix(filepath.Base(frame), filepath.Ext(frame))
	outFile, err := os.Create(filepath.Join(asciiDir, name))
	if err != nil {
		fatal("Failed to create output file", err)
	}
	defer outFile.Close()

	cmd := exec.Command("jp2a", "--colors", "--width="+width, frame)
	cmd.Stdout = outFile
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		fatal("jp2a failed on "+frame, err)
	}
}

func main() {
	if len(os.Args) < 3 {
		fmt.Fprintln(os.Stderr, "Usage: ascii-frames <video-path> <width>")
		os.Exit(1)
	}

	videoPath := os.Args[1]
	width := os.Args[2]

	framesDir := mkTemp("ascii-frames-")
	asciiDir := mkTemp("ascii-frames-out-")

	extractFrames(videoPath, framesDir)
	convertToAscii(framesDir, asciiDir, width)

	fmt.Println("Done. ASCII frames saved to", asciiDir)
}
