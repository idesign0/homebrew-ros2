# 🍺 Homebrew ROS 2 (Prebuilt Binaries for macOS)

This repository provides a Homebrew tap for installing **prebuilt ROS 2 distributions on macOS (Apple Silicon / ARM64)**.

Instead of building ROS 2 from source (which is slow and error-prone on macOS), this tap installs **ready-to-use binaries** built from:

👉 https://github.com/idesign0/ros2_macOS

---

## 🚀 What You Get

- Prebuilt ROS 2 distributions (e.g. humble)
- Core ROS 2 tooling and ecosystem packages
- macOS-specific fixes and toolchain adjustments
- Faster installs (minutes instead of hours)

---

## 📦 Installation

### 1. Add the Tap

```bash
brew update
brew tap idesign0/ros2
```

### 2. Install ROS 2

```bash
brew install ros2-humble
```

---

## 🧠 How It Works

- This tap contains **Homebrew formulae** that:
  - Download prebuilt ROS 2 binaries from the `ros2_macOS` repository
  - Extract and link them into your Homebrew prefix
- Avoids full source compilation
- Ensures consistency across systems

---

## Prerequisites

## Prerequisites

### Python 3.11 (python.org — required)

This project requires **Python 3.11 from [python.org](https://www.python.org/downloads/macos/)**. Homebrew Python is not supported and must be unlinked to avoid conflicts.

**1. Verify the framework Python is installed:**
```bash
ls /Library/Frameworks/Python.framework/Versions/3.11/bin/python3
```

**2. Unlink Homebrew Python** (adjust the version number if needed):
```bash
brew unlink python@3.14
```

**3. Confirm the correct Python is active:**
```bash
which python3
# Expected: /Library/Frameworks/Python.framework/Versions/3.11/bin/python3
```

> **Why this matters:** Even after installing the framework Python, some packages will silently fall back to Homebrew Python if it's still linked. Unlinking it ensures the entire toolchain uses the correct interpreter.
---

## ⚙️ Environment Setup

After installation, you need to source ROS 2 and Gazebo Paths:

```bash
source /opt/homebrew/opt/ros2-humble/setup.zsh

export GZ_SIM_SYSTEM_PLUGIN_PATH=/opt/homebrew/opt/ros2-humble/lib/gz-sim-8/plugins
export GZ_SIM_PHYSICS_ENGINE_PATH=/opt/homebrew/opt/ros2-humble/lib/gz-physics-7/engine-plugins
export GZ_SIM_RESOURCE_PATH=/opt/homebrew/opt/ros2-humble/share/gz/gz-sim8/worlds:/opt/homebrew/opt/ros2-humble/share/gz/gz-sim8/models
export GZ_GUI_PLUGIN_PATH=/opt/homebrew/opt/ros2-humble/lib/gz-sim-8/plugins/gui:/opt/homebrew/opt/ros2-humble/lib/gz-gui-8/plugins
export QML2_IMPORT_PATH=/opt/homebrew/opt/ros2-humble/lib/gz-sim-8/plugins/gui
export GZ_RENDERING_PLUGIN_PATH=/opt/homebrew/opt/ros2-humble/lib/gz-rendering-8/engine-plugins
export GZ_RENDERING_RESOURCE_PATH=/opt/homebrew/opt/ros2-humble/share/gz/gz-rendering8

### Optional: Add to your shell config

```bash
echo 'source $(brew --prefix)/opt/ros2-humble/setup.zsh' >> ~/.zshrc
```

---

## 🔄 Updating

```bash
brew upgrade ros2-humble
```

---

## 🧩 Available Packages

Currently supported:

- `ros2-jazzy`
- `ros2-kilted`
- `ros2-humble`

More distributions may be added in the future.

---

## 🛠 Troubleshooting

### ❌ catkin_pkg not found

```bash
# python version can change. it should be confirmed from error log
brew unlink python3.14 
```

### ❌ Not linked properly

```bash
brew link --overwrite ros2-humble
```

### ❌ Missing dependencies

Run:

```bash
brew install <missing-package>
```

### ❌ Environment not working

Make sure you sourced the setup script:

```bash
source $(brew --prefix)/opt/ros2-humble/setup.zsh
```

---

## ⚠️ Notes

- Designed for **Apple Silicon (ARM64)**
- Built using custom toolchains to work with Homebrew and Xcode
- Some packages may differ slightly from official ROS 2 releases due to macOS constraints
