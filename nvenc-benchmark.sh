#!/bin/bash

start(){
  cleanup
#  dep_check
  start_container
}

dep_check(){
  if ! command -v jq >/dev/null; then
    echo "jq missing. Please install jq"
    exit 127
  fi
  if ! command -v nvidia-smi >/dev/null; then
    echo "nvidia-smi missing. Please install NVIDIA drivers"
    exit 127
  fi
  if ! command -v printf >/dev/null; then
    echo "printf missing. Please install printf"
    exit 127
  fi
  if ! command -v docker >/dev/null; then
    echo "Docker missing. Please install Docker"
    exit 127
  fi
  if ! command -v nvidia-container-runtime >/dev/null; then
    echo "nvidia-container-runtime missing. Please install nvidia-docker"
    exit 127
  fi
  if ! command -v nvidia-docker >/dev/null; then
    echo "Docker is not configured with nvidia runtime. Please configure nvidia-docker"
    exit 127
  fi
  if ! command -v docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi >/dev/null 2>&1; then
    echo "nvidia-docker is not functioning correctly. Please check the setup"
    exit 127
  fi
}

cleanup(){
  #Delete any previous report file
  rm -rf ffmpeg*.log
  rm -rf *.output
  
  # Stop and remove any existing jellyfin-nvenctest container
  docker stop jellyfin-nvenctest >/dev/null 2>&1
  docker rm jellyfin-nvenctest >/dev/null 2>&1
  
  # Remove jellyfin image if it exists
#  docker rmi jellyfin/jellyfin >/dev/null 2>&1
}

start_container(){
  docker pull jellyfin/jellyfin >/dev/null
  docker run --rm -it -d --name jellyfin-nvenctest --gpus all -v $(pwd):/config jellyfin/jellyfin >/dev/null
  sleep 5s
  if $(docker inspect jellyfin-nvenctest | jq -r '.[].State.Running'); then
    main
  else
    echo "Jellyfin NVENC test container not running"
    exit 127
  fi
}

stop_container(){
  docker stop jellyfin-nvenctest > /dev/null
  docker rm jellyfin-nvenctest > /dev/null
}

benchmarks(){
  nvidia-smi --query-gpu=timestamp,power.draw --format=csv,noheader,nounits -l 1 -f $1.output &
  nvsmi_pid=$!
  docker exec -it jellyfin-nvenctest /config/benchmark_nvenc.sh $1
  kill -s SIGINT $nvsmi_pid
  #Calculate average Wattage
  if [ $1 != "h264_1080p_cpu" ]; then
    avg_watts=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits)
    gpu_model=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits) 

  else
    total_watts=$(awk -F, '{print $2}' $1.output | paste -s -d + - | bc)
    total_count=$(wc -l < $1.output)
    avg_watts=$(echo "scale=2; $total_watts / $total_count" | bc -l)
    gpu_model=$(grep -m1 'model name' /proc/cpuinfo | cut -d':' -f2)


  fi
  for i in $(ls ffmpeg-*.log); do
    #Calculate average FPS
    total_fps=$(grep -Eo 'fps=.[1-9][1-9].' $i | sed -e 's/fps=//' | paste -s -d + - | bc)
    fps_count=$(grep -Eo 'fps=.[1-9][1-9].' $i | wc -l)
    avg_fps=$(echo "scale=2; $total_fps / $fps_count" | bc -l)
   #Calculate average speed
    total_speed=$(grep -Eo 'speed=[0-9].[0-9].' $i | sed -e 's/speed=//' | paste -s -d + - | bc)
    speed_count=$(grep -Eo 'speed=[0-9].[0-9].' $i | sed -e 's/speed=//' | wc -l)
    avg_speed="$(echo "scale=2; $total_speed / $speed_count" | bc -l)x"
    #Get Bitrate of file
    bitrate=$(grep -Eo 'bitrate: [1-9].*' $i | sed -e 's/bitrate: //')
    #Get time to convert
    total_time=$(grep -Eo 'rtime=[1-9].*s' $i | sed -e 's/rtime=//')
    #delete log file
    rm -rf $i
    rm -rf $1.output
  done
  #Add data to array
  nvencstats_arr+=("$gpu_model|$1|$2|$bitrate|$total_time|$avg_fps|$avg_speed|$avg_watts")
  clear_vars
}

clear_vars(){
 for i in total_watts total_count avg_watts total_fps fps_count avg_fps total_speed speed_count avg_speed bitrate total_time; do
   unset $i
 done
}

main(){
  #Sets Array
  nvencstats_arr=("GPU|TEST|FILE|BITRATE|TIME|AVG_FPS|AVG_SPEED|AVG_WATTS")
  driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)
  #Collects GPU Model
  benchmarks h264_1080p_cpu ribblehead_1080p_h264
  benchmarks h264_1080p ribblehead_1080p_h264
  benchmarks h264_4k ribblehead_4k_h264
  benchmarks hevc_8bit ribblehead_1080p_hevc_8bit
  benchmarks hevc_4k_10bit ribblehead_4k_hevc_10bit
  #Print Results
  printf "NVIDIA driver version ${driver_version}"
  printf "\n"
  printf '%s\n' "${nvencstats_arr[@]}" | column -t -s '|'
  printf "\n"
  #Unset Array
  unset nvencstats_arr
  stop_container
}

start
