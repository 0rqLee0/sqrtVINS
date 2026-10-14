#!/bin/bash
# 容器内运行：run_serial <config_yaml> <bag> <out_dir>
# 输出 <out_dir>/traj.txt（TUM: t x y z qx qy qz qw，IMU 在世界系位姿）
cfg=$1; bag=$2; out=$3
source /opt/ros/noetic/setup.bash; source /catkin_ws/devel/setup.bash
mkdir -p $out
roslaunch ov_srvins serial_eval.launch config_path:=$cfg bag:=$bag path_est:=$out/state_estimate.txt &
lp=$!
wait $lp; rc=$?
# JPL q_GtoI(xyzw) 数值上等于 Hamilton q_ItoG，直接按 TUM 顺序输出
[ -s $out/state_estimate.txt ] && awk '!/^#/ && NF>=8 {print $1,$6,$7,$8,$2,$3,$4,$5}' $out/state_estimate.txt > $out/traj.txt
echo "[run_serial] roslaunch rc=$rc lines=$(wc -l < $out/traj.txt 2>/dev/null)"
