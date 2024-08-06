
Runs an ffmpeg benchmark to get Average Speed, FPS, and Watts folked from ironicbadger/quicksync_calc
===========================================

The purpose of this script is to benchmark Nvidia NVENC, Intel Quick Sync Video performance in integrated iGPUs and dGPU using standardised video. More information and rationale is available [at blog.ktz.me](https://blog.ktz.me/i-need-your-help-with-intel-quick-sync-benchmarking/).

Some conclusions and analysis has now been performed (May 2024), you can read about it [https://blog.ktz.me/the-best-media-server-cpu-in-the-world/](https://blog.ktz.me/the-best-media-server-cpu-in-the-world/).

REQUIREMENTS
------------

For Intel_qsv:
Requires Docker, Intel CPU w/ QuickSync, printf, and intel-gpu-tools package. Designed for Linux. Tested on Proxmox 8 and Ubuntu 22.04.

For Nvidia_nvenc
Requires docker-nvidia, Nvidia GPU with nvenc and nvidia-smi tool for stats. Tested on Ubuntu 

Install [Nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

This should be run as root with no other applications/containers running that would utilize quicksync. This includes Desktop Environments.

HOW TO USE
------------

Full instructions available at [blog.ktz.me](https://blog.ktz.me/i-need-your-help-with-intel-quick-sync-benchmarking/).

```
# connect to the system you want the benchmark on (likely via ssh)
ssh user@hostname

# install a couple of dependencies (script tested on proxmox 8 + ubuntu 22.04)
For Intel
apt install docker.io jq bc intel-gpu-tools git


For NVIDIA
For Nvidia-container-toolkit refer => https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html 
apt install docker.io jq bc git nvidia-container-toolkit


# clone the git repo with the script
git clone https://github.com/akdrag/nvenc_calc.git

# change directory into the cloned repo
cd nvenc_calc

# download the test videos and run the benchmark
./enter-benchmark.sh

```


Check out the results.

SAMPLE OUTPUTS
------------
```bash
CPU      TEST            FILE                        BITRATE     TIME      AVG_FPS  AVG_SPEED  AVG_WATTS
i5-9500  h264_1080p_cpu  ribblehead_1080p_h264       18952 kb/s  59.665s   58.03    2.05x      N/A
i5-9500  h264_1080p      ribblehead_1080p_h264       18952 kb/s  15.759s   232.03   7.63x      7.66
i5-9500  h264_4k         ribblehead_4k_h264          46881 kb/s  58.667s   59.21    2.09x      7.49
i5-9500  hevc_8bit       ribblehead_1080p_hevc_8bit  14947 kb/s  45.369s   76.10    2.66x      9.09
i5-9500  hevc_4k_10bit   ribblehead_4k_hevc_10bit    44617 kb/s  176.932s  19.71    .68x       10.12
```

```bash
CPU       TEST            FILE                        BITRATE     TIME      AVG_FPS  AVG_SPEED  AVG_WATTS
i5-8500T  h264_1080p_cpu  ribblehead_1080p_h264       18952 kb/s  87.080s   42.86    1.46x      N/A
i5-8500T  h264_1080p      ribblehead_1080p_h264       18952 kb/s  18.928s   182.45   6.31x      9.09
i5-8500T  h264_4k         ribblehead_4k_h264          46881 kb/s  69.238s   49.52    1.75x      9.04
i5-8500T  hevc_8bit       ribblehead_1080p_hevc_8bit  14947 kb/s  45.061s   76.42    2.67x      11.93
i5-8500T  hevc_4k_10bit   ribblehead_4k_hevc_10bit    44617 kb/s  185.816s  18.85    .65x       13.13
```

```bash
NVIDIA driver version 545.29.02
GPU                                               TEST            FILE                        BITRATE     TIME      AVG_FPS  AVG_SPEED  AVG_WATTS
Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz  h264_1080p_cpu  ribblehead_1080p_h264       18952 kb/s  171.607s  20.33    .76x       
NVIDIA GeForce GTX 1650 SUPER                     h264_1080p      ribblehead_1080p_h264       18952 kb/s  19.813s   169.40   6.13x      32.41
NVIDIA GeForce GTX 1650 SUPER                     h264_4k         ribblehead_4k_h264          46881 kb/s  79.479s   42.30    1.57x      30.54
NVIDIA GeForce GTX 1650 SUPER                     hevc_8bit       ribblehead_1080p_hevc_8bit  14947 kb/s  27.561s   124.62   4.40x      31.70
NVIDIA GeForce GTX 1650 SUPER                     hevc_4k_10bit   ribblehead_4k_hevc_10bit    44617 kb/s  104.627s  32.70    1.17x      32.60
```

```bash
NVIDIA driver version 545.29.06
GPU                                   TEST                       FILE                        INP_BITRATE1  INP_BITRATE2    TIME      AVG_FPS  AVG_SPEED  AVG_WATTS
 AMD Ryzen 9 5900X 12-Core Processor  h264_1080p_cpu             ribblehead_1080p_h264       18952 kb/s                    23.235s   139.27   5.30x      
NVIDIA GeForce RTX 3080 Ti            h264_1080p                 ribblehead_1080p_h264       18952 kb/s                    20.071s   169.27   6.17x      135.62
NVIDIA GeForce RTX 3080 Ti            h264_4k                    ribblehead_4k_h264          46881 kb/s                    81.326s   41.23    1.54x      144.96
NVIDIA GeForce RTX 3080 Ti            hevc_8bit                  ribblehead_1080p_hevc_8bit  14947 kb/s                    28.112s   122.00   4.35x      145.72
NVIDIA GeForce RTX 3080 Ti            hevc_4k_10bit              ribblehead_4k_hevc_10bit    44617 kb/s                    107.733s  31.69    1.15x      147.97
NVIDIA GeForce RTX 3080 Ti            multistream_encoding_h264  multistream_x4_h264         18952 kb/s    46881 kb/s      286.420s  11.92    .38x       146.48
NVIDIA GeForce RTX 3080 Ti            multistream_encoding_hevc  multistream_x4_hevc         14947 kb/s    44617 kb/s      273.322s  12.69    .40x       146.45

```