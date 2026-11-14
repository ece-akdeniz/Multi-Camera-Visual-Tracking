# Multi-camera visual tracking for flight robotics

Course project for **BEFR** — *Bayesian Estimation for Flight Robotics* (SoSe 2026) — at the [Institute of Flight Mechanics and Flight Control (IFR)](https://www.ifr.uni-stuttgart.de/), University of Stuttgart.

**Authors:** Ece Akdeniz, Lars Wolfgramm-Kuntz  
**Repository:** [github.com/ece-akdeniz/multi-camera-visual-tracking-flight-robotics](https://github.com/ece-akdeniz/multi-camera-visual-tracking-flight-robotics)

**Summary:** Multi-camera Bayesian state estimation and self-calibration for a simulated quadcopter (KF, EKF, UKF, bundle adjustment, ROS 2 optional, Streamlit dashboard).

## Overview

This repository implements a complete pipeline for estimating the six-dimensional pose and velocity of a quadcopter from **multi-camera pixel measurements** only. Several fixed pinhole cameras observe a single point on the vehicle (the projection of its position). No depth, onboard attitude, or inter-camera time synchronization is assumed beyond what the sensor node provides.

The state vector is

\[
\mathbf{x} = [p_x, p_y, p_z, v_x, v_y, v_z]^\top .
\]

The project covers two course tasks:

1. **Basic task (Task 1)** — Given known camera intrinsics and extrinsics, fuse noisy detections with a constant-velocity motion model using a **linear Kalman filter (KF)**, an **extended Kalman filter (EKF)** with a direct pixel measurement model, and an **unscented Kalman filter (UKF)**.
2. **Advanced task** — Estimate unknown camera poses and a short target trajectory jointly via **bundle adjustment**, with gauge fixing and evaluation against ground truth.

The same mathematical core is shared by offline batch experiments, an optional **ROS 2** stack (Gazebo ground truth), and a **Streamlit** dashboard for inspection and replay.

## How it works

```text
Gazebo odometry (optional)  →  camera simulator  →  pixel (u, v) per camera
                                      ↓
                    triangulation (KF)  /  pixel update (EKF, UKF)
                                      ↓
                         state estimate + experiment logs
```

| Stage | Role |
|-------|------|
| **Camera model** | Pinhole projection, visibility, pixel noise, optical-frame convention |
| **Triangulation** | Least-squares intersection of viewing rays (KF measurement) |
| **Filters** | Shared `TrackerBase` interface; comparable tuning and metrics |
| **Experiments** | One variable changed at a time; outputs under `results/experiment_NNN/` |
| **Calibration** | OpenCV or ground-truth init, trajectory initialization, scipy BA, YAML export |

Each saved experiment folder contains `detections.csv`, `estimates.csv`, `ground_truth.csv`, `camera_config.yaml`, `metadata.json`, and `metrics.json`, so results can be reproduced and plotted without rerunning Gazebo.

## Repository layout

| Path | Description |
|------|-------------|
| `befr_visual_tracking/` | Python package: geometry, filters, experiment runner, calibration |
| `config/` | Camera layouts, filter defaults, experiment plan (`experiments_plan.yaml`) |
| `dashboard/` | Streamlit UI for saved runs and interactive offline replay |
| `results/` | Canonical datasets, experiment outputs, calibration sequences |
| `launch/` | ROS 2 launch files (camera sim, tracking, recording) |
| `tests/` | Unit tests (`pytest`) |
| `presentation/` | Slides and exported figures |
| `VM_STARTUP.md` | Command cheat sheet for Gazebo on a Linux VM |

## Requirements

- Python 3.10+ (3.12 tested)
- Dependencies: `numpy`, `scipy`, `PyYAML`, `streamlit`, `plotly`, `pandas` (see `requirements.txt`)
- **Optional:** ROS 2 Humble or newer, Gazebo/Ignition sim from the course repo `BEFR_SS_2026` (`rrbot_gazebo`)

## Installation

From the repository root:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip install -e .
```

Run tests:

```bash
python3 -m pytest tests/ -q
```

## Using the repository

### 1. Offline experiments (no simulator)

List and run planned experiments (see `config/experiments_plan.yaml`):

```bash
python3 -m befr_visual_tracking.run_experiments --list
python3 -m befr_visual_tracking.run_experiments --experiment 0
python3 -m befr_visual_tracking.run_experiments --experiment 1 --filter ekf
```

Advanced calibration on a saved dataset:

```bash
python3 -m befr_visual_tracking.run_calibration results/calibration_figure_eight_3d --compare-tracking
```

Summaries of selected runs: `OFFLINE_RESULTS.md`.

### 2. Dashboard

```bash
streamlit run dashboard/streamlit_app.py
```

Open [http://localhost:8501](http://localhost:8501). The app supports loading completed `results/experiment_NNN/` folders and regenerating detections for interactive KF/EKF/UKF comparison, 3D views, time-series errors, and calibration views.

### 3. ROS 2 and Gazebo (optional)

Build in a colcon workspace that contains this package and the course simulation:

```bash
colcon build --packages-select befr_visual_tracking
source install/setup.bash
ros2 launch rrbot_gazebo rrbot_world.launch.py   # course sim, separate repo
ros2 launch befr_visual_tracking tracking.launch.py filter_type:=ekf launch_camera_simulator:=true
```

Ground truth defaults to `/model/rrbot/odometry`. Step-by-step terminals and troubleshooting: `VM_STARTUP.md`.

## Experiment programme (Task 1)

| ID | Focus |
|----|--------|
| 0 | Zero noise — geometry sanity check |
| 1 | Filter comparison (KF / EKF / UKF) |
| 2 | Number of active cameras |
| 3 | Pixel noise level |
| 4 | Detection dropout |
| 5 | Camera baseline / layout |
| 6 | Motion model vs. manoeuvre |
| 7 | Orbit radius / target distance |

Advanced calibration experiments (IDs 101–104) are described in `config/experiments_plan.yaml` and `OFFLINE_RESULTS.md`.

## Figures and presentation

Pre-rendered Plotly HTML and slide assets live under `presentation/` and `befr_visual_tracking/notebooks/final_vis_figures/`. To regenerate Task 1 plots from a results folder:

```bash
python befr_visual_tracking/notebooks/run_final_vis.py --results-dir results/three_camera_takeoff_circles4
```

Additional notebook scripts generate advanced calibration and observability figures; source notebook: `befr_visual_tracking/notebooks/final_vis.ipynb`.

## Citation and context

Course material: *Bayesian Estimation for Flight Robotics* (IFR, Universität Stuttgart). The implementation follows a pinhole camera and Bayesian filtering treatment aligned with the course project specification (multi-camera visual tracking and optional self-calibration).

For questions about reproduction, start with experiment 0, then the dashboard page **Filter comparison** on `experiment_005`–`007`.