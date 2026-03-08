# extract all the frame from the video $1 to the folder $2

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "need 2 argument to run"
  echo "exemple:"
  echo "sh getFrames.sh video.mp4 framesFolder"
  return
fi

ffmpeg -i "$1" "$2/${1%.*}_frame_%04d.png"

