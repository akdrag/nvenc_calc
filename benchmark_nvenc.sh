#!/bin/bash

benchmark(){

case "$1" in
    h264_1080p_cpu)
      h264_1080p_cpu
      ;;

    h264_1080p)
      h264_1080p
      ;;

    h264_4k)
      h264_4k
      ;;

    hevc_8bit)
      hevc_8bit
      ;;

    hevc_4k_10bit)
      hevc_4k_10bit
      ;;
  esac
}

h264_1080p_cpu(){
  echo "=== CPU only test"
  echo "h264_1080p_cpu - h264 to h264 cpu starting."
  /usr/lib/jellyfin-ffmpeg/ffmpeg -y -hide_banner -benchmark -report -i /config/ribblehead_1080p_h264.mp4 -c:a copy -c:v libx264 -look_ahead 10 -f null - 2>/dev/null
}

h264_1080p(){
  echo "=== NVENC test"
  echo "h264_1080p - h264 to h264_nvenc starting."
  /usr/lib/jellyfin-ffmpeg/ffmpeg -y -hide_banner -benchmark -report -hwaccel cuda -hwaccel_output_format cuda -i /config/ribblehead_1080p_h264.mp4 -c:a copy -c:v h264_nvenc -preset slow -cq 18 -look_ahead 10 -f null - 2>/dev/null
}

h264_4k(){
  echo "=== NVENC test"
  echo "h264_4k - h264 to h264_nvenc starting."
  /usr/lib/jellyfin-ffmpeg/ffmpeg -y -hide_banner -benchmark -report -hwaccel cuda -hwaccel_output_format cuda -i /config/ribblehead_4k_h264.mp4 -c:a copy -c:v h264_nvenc -preset slow -cq 18 -look_ahead 10 -f null - 2>/dev/null
}

hevc_8bit(){
  echo "=== NVENC test"
  echo "hevc_1080p_8bit - hevc 8bit to hevc_nvenc starting."
  /usr/lib/jellyfin-ffmpeg/ffmpeg -y -hide_banner -benchmark -report -hwaccel cuda -hwaccel_output_format cuda -i /config/ribblehead_1080p_hevc_8bit.mp4 -c:a copy -c:v hevc_nvenc -preset slow -cq 18 -look_ahead 10 -f null - 2>/dev/null
}

hevc_4k_10bit(){
  echo "=== NVENC test"
  echo "hevc_4k - hevc 10bit to hevc_nvenc starting."
  /usr/lib/jellyfin-ffmpeg/ffmpeg -y -hide_banner -benchmark -report -hwaccel cuda -hwaccel_output_format cuda -i /config/ribblehead_4k_hevc_10bit.mp4 -c:a copy -c:v hevc_nvenc -preset slow -cq 18 -look_ahead 10 -f null - 2>/dev/null
}

cd /config

benchmark $1
