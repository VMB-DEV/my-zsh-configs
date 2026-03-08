if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "need 3 argument to run"
  echo "origin folder, target folder, width number"
  echo "exemple:"
  echo "sh generateAsciiFrames.sh png_frames_folder ascii_frames_folder"
  return
fi

for f in frames/frame_*.png;
do
  jp2a --colors --width=$3 "$f" > "$2/$(basename "${f%.png}")";
done
