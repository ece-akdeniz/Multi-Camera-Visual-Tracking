#!/bin/bash
# Quick live validation: compare ground truth vs state estimate (run while stack is up).
set -eo pipefail

# ROS setup.bash uses unset vars; do not enable nounset (-u) before sourcing.
source /opt/ros/humble/setup.bash
source ~/BEFR_SS_2026/install/setup.bash
source ~/BEFR-Project/install/setup.bash

echo "=== Clock (sim must be running) ==="
timeout 3 ros2 topic hz /clock 2>/dev/null || echo "WARNING: /clock not publishing — press Play in Gazebo"

echo ""
echo "=== Motor controllers ==="
ros2 control list_controllers -c /rrbot/controller_manager 2>/dev/null || echo "WARNING: controller_manager not available"

echo ""
echo "=== Ground truth (one sample) ==="
timeout 5 ros2 topic echo /model/rrbot/odometry --once 2>/dev/null || echo "WARNING: no odometry"

echo ""
echo "=== State estimate (one sample) ==="
timeout 5 ros2 topic echo /visual_tracking/state_estimate --once 2>/dev/null || echo "WARNING: no state estimate — is tracking launch running?"

echo ""
echo "=== Detection rate (3 s) ==="
timeout 3 ros2 topic hz /visual_tracking/camera_0/detection 2>/dev/null || echo "WARNING: no detections"

echo ""
echo "Target: GT z ≈ 3–8 m (square_ctrl); estimate should be within ~1–2 m of GT."
echo "Cameras use config/cameras_gazebo.yaml (center z=5 m) by default."
