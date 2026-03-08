# extract all the frame from the video $1 to the folder $2
# $ sh getFrames.sh video.mp4 framesFolder

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "need 2 argument to run"
  echo "exemple:"
  echo "sh getFrames.sh video.mp4 framesFolder"
  return
fi

VIDEO_NAME="${1%.*}"
VIDEO_FRAME_FOLDER="${VIDEO_NAME}_frame_png"
mkdir "$2/$VIDEO_FRAME_FOLDER"
ffmpeg -i "$1" "$2/${VIDEO_FRAME_FOLDER}_frame_%04d.png"

