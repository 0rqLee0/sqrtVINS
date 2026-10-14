# sqrtVINS (ROS1 Noetic, Ubuntu 20.04) — 离线 serial 回放 rosbag（ros1_serial_msckf）
# 构建: cd /home/lee/sqrtVINS && docker build -f docker/Dockerfile -t sqrtvins:latest .
# 依赖参照仓库根目录 Dockerfile_ros1_20_04（去掉 clion/sshd 部分，基于 perception 镜像以复用 cv_bridge/tf）
FROM ros:noetic-perception

RUN apt-get update && apt-get install -y --no-install-recommends \
      git nano cmake build-essential libeigen3-dev libsuitesparse-dev \
      libopencv-dev libopencv-contrib-dev libboost-all-dev \
      python3-catkin-tools python3-osrf-pycommon \
      ros-noetic-cv-bridge ros-noetic-image-transport ros-noetic-tf \
      ros-noetic-nav-msgs ros-noetic-visualization-msgs ros-noetic-rosbag && \
    rm -rf /var/lib/apt/lists/*

ENV CATKIN_WS=/catkin_ws
RUN mkdir -p $CATKIN_WS/src/sqrtVINS
COPY ov_core  $CATKIN_WS/src/sqrtVINS/ov_core
COPY ov_srvins $CATKIN_WS/src/sqrtVINS/ov_srvins
COPY config   $CATKIN_WS/src/sqrtVINS/config

# 唯一源码改动：bag 处理完后向 stderr 打完成标记（进程退出时 image_transport 插件卸载会 abort(-6)，
# stdout 缓冲丢失，roslaunch 也报 died，无法据此判断成败；轨迹逐行 endl 已落盘不受影响）
RUN sed -i 's|^  // Final visualization$|  fprintf(stderr, "[SERIAL]: Done!\\n");\n  // Final visualization|' \
      $CATKIN_WS/src/sqrtVINS/ov_srvins/src/ros1_serial_msckf.cpp && \
    grep -q 'SERIAL\]: Done' $CATKIN_WS/src/sqrtVINS/ov_srvins/src/ros1_serial_msckf.cpp

WORKDIR $CATKIN_WS
RUN . /opt/ros/noetic/setup.sh && \
    catkin config --extend /opt/ros/noetic --cmake-args -DCMAKE_BUILD_TYPE=Release && \
    catkin build ov_srvins -j8 && \
    sed -i '/exec "$@"/i source "/catkin_ws/devel/setup.bash"' /ros_entrypoint.sh

COPY docker/serial_eval.launch $CATKIN_WS/src/sqrtVINS/ov_srvins/launch/serial_eval.launch
COPY docker/run_serial.sh /usr/local/bin/run_serial
RUN chmod +x /usr/local/bin/run_serial
