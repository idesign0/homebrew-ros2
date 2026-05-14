# 🍺 Homebrew ROS 2 (Prebuilt Binaries for macOS)

This repository provides a Homebrew tap for installing **prebuilt ROS 2 distributions on macOS (Apple Silicon / ARM64)**.

Instead of building ROS 2 from source (which is slow and error-prone on macOS), this tap installs **ready-to-use binaries** built from:

👉 https://github.com/idesign0/ros2_macOS

---

## 🚀 What You Get

- Prebuilt ROS 2 distributions (e.g. Jazzy)
- Core ROS 2 tooling and ecosystem packages
- macOS-specific fixes and toolchain adjustments
- Faster installs (minutes instead of hours)

---

## 📦 Installation

### 1. Add the Tap

```bash
brew tap idesign0/ros2
```

### 2. Install ROS 2

```bash
brew install ros2-jazzy
```

---

## 🧠 How It Works

- This tap contains **Homebrew formulae** that:
  - Download prebuilt ROS 2 binaries from the `ros2_macOS` repository
  - Extract and link them into your Homebrew prefix
- Avoids full source compilation
- Ensures consistency across systems

---

## ⚙️ Environment Setup

After installation, you need to source ROS 2:

```bash
source $(brew --prefix)/opt/ros2-jazzy/setup.zsh
```

### Optional: Add to your shell config

```bash
echo 'source $(brew --prefix)/opt/ros2-jazzy/setup.zsh' >> ~/.zshrc
```

---

## 🔄 Updating

```bash
brew update
brew upgrade ros2-jazzy
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

### ❌ Not linked properly

```bash
brew link --overwrite ros2-jazzy
```

### ❌ Missing dependencies

Run:

```bash
brew install <missing-package>
```

### ❌ Environment not working

Make sure you sourced the setup script:

```bash
source $(brew --prefix)/opt/ros2-jazzy/setup.zsh
```

---

## ⚠️ Notes

- Designed for **Apple Silicon (ARM64)**
- Built using custom toolchains to work with Homebrew and Xcode
- Some packages may differ slightly from official ROS 2 releases due to macOS constraints
