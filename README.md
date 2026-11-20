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
# Both taps must be trusted. Since Homebrew 4.x, loading ANY formula from an
# untrusted third-party tap is refused, and these formulae depend on Ogre from
# osrf/simulation, so trusting this tap alone is not enough:
#   Error: Refusing to load formula osrf/simulation/ogre2.3 from untrusted tap
brew trust idesign0/ros2
brew trust osrf/simulation

brew install ros2-humble
```

> **Why several `osrf/simulation` formulae appear in the refusal messages.**
> Homebrew refuses to *load* any formula from an untrusted tap while it resolves
> dependencies, so names like `ogre2.2`, `sdformat14` and `gz-cmake3` can show up even
> though ROS 2 only depends on `ogre1.9` and `ogre2.3`. Trusting the tap once clears all
> of them; you do not need to install those formulae yourself.

---

## 🧠 How It Works

- This tap contains **Homebrew formulae** that:
  - Download prebuilt ROS 2 binaries from the `ros2_macOS` repository
  - Extract and link them into your Homebrew prefix
- Avoids full source compilation
- Ensures consistency across systems

---

## Prerequisites

### Python 3.11 (python.org — required)

This project requires **Python 3.11 from [python.org](https://www.python.org/downloads/macos/)**.

> ⚠️ **Homebrew Python is NOT supported** (`brew install python@3.11` will not work). The prebuilt ROS 2 binaries are linked against the python.org framework Python at `/Library/Frameworks/Python.framework/Versions/3.11/`. Homebrew Python lives at a different path and must be unlinked to avoid conflicts.

**1. Install Python 3.11 from python.org:**

Download the **macOS 64-bit universal2 installer** from https://www.python.org/downloads/macos/ and:

1. Run the Installation Wizard (default settings)
2. Run `Install Certificates.command` from `/Applications/Python 3.11/`
3. Run `Update Shell Profile.command` (or add the PATH manually, see step 3 below)

**2. Unlink Homebrew Python** (adjust the version number if needed):
```bash
brew unlink python@3.14
```

**3. Add Python 3.11 to your `~/.zshrc`:**
```zsh
# Python 3.11 framework path
export PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:$HOME/Library/Python/3.11/bin:$PATH"

# Python pip aliases for convenience
alias pip3.11="python3.11 -m pip"
```

> 💡 Use `python3 -m pip` (instead of just `pip`) to avoid confusion between Python installations. Do **not** add aliases like `alias python3=python3.11` — the PATH export above is enough, and aliases interfere with the verification below.

**4. Confirm the correct Python is active** (open a new terminal first):
```bash
which python3
# Expected: /Library/Frameworks/Python.framework/Versions/3.11/bin/python3

which pip
# Expected: /Library/Frameworks/Python.framework/Versions/3.11/bin/pip
```

> **Why this matters:** The ROS 2 executables and linked libraries resolve against the framework Python. Even after installing it, some packages will silently fall back to Homebrew Python if it's still linked. Unlinking it ensures the entire toolchain uses the correct interpreter.

---

### Python dependencies (required)

Install these once, into the python.org 3.11. The ROS 2 CLI will not run without them,
and they surface one at a time as you use different subcommands — `No module named
'yaml'`, then `'packaging'`, then `Failed to load entry point 'launch': No module named
'lark'`, then `'doctor': No module named 'numpy'`.

```bash
pip3.11 install empy==3.3.4 lark==1.1.1 catkin_pkg netifaces osrf-pycommon \
  PyYAML packaging psutil typeguard jinja2 lxml numpy
```

Verify — this should print with no `Failed to load entry point` lines:

```bash
ros2 --help
```

---

## ⚙️ Environment Setup

Source the distribution you installed:

```bash
source /opt/homebrew/opt/ros2-jazzy/setup.zsh     # or ros2-kilted / ros2-humble
```

### Gazebo

**Jazzy and Kilted: nothing to export.** Gazebo ships inside the keg (`opt/gz_*_vendor`), and
`setup.zsh` sets its plugin, resource and config paths. Do not export `GZ_*` or
`QML2_IMPORT_PATH` yourself. If your `~/.zshrc` still has the exports from an older version of
this README, delete them: they point at `share/gz` and `lib/gz-*` paths that no longer exist,
and the Gazebo window opens with an empty 3D view.

Check, after sourcing:

```bash
echo $GZ_CONFIG_PATH | tr ':' '\n' | head -3
# Expected: /opt/homebrew/opt/ros2-jazzy/opt/gz_..._vendor/share/gz lines
```

**Humble** (release 26.10.12.325) is still packaged the old way and needs the exports:

```bash
export GZ_SIM_SYSTEM_PLUGIN_PATH=/opt/homebrew/opt/ros2-humble/lib/gz-sim-8/plugins
export GZ_SIM_PHYSICS_ENGINE_PATH=/opt/homebrew/opt/ros2-humble/lib/gz-physics-7/engine-plugins
export GZ_SIM_RESOURCE_PATH=/opt/homebrew/opt/ros2-humble/share/gz/gz-sim8/worlds:/opt/homebrew/opt/ros2-humble/share/gz/gz-sim8/models
export GZ_GUI_PLUGIN_PATH=/opt/homebrew/opt/ros2-humble/lib/gz-sim-8/plugins/gui:/opt/homebrew/opt/ros2-humble/lib/gz-gui-8/plugins
export QML2_IMPORT_PATH=/opt/homebrew/opt/ros2-humble/lib/gz-sim-8/plugins/gui
export GZ_RENDERING_PLUGIN_PATH=/opt/homebrew/opt/ros2-humble/lib/gz-rendering-8/engine-plugins
export GZ_RENDERING_RESOURCE_PATH=/opt/homebrew/opt/ros2-humble/share/gz/gz-rendering8
```

`brew info ros2-<distro>` always shows the setup for the version you have installed.

### Middleware for large launches (Nav2, TurtleBot, MoveIt)

For launches with dozens of nodes, Cyclone DDS with this profile is the most reliable setup we
have found on macOS:

```bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI='<CycloneDDS><Domain><General><Interfaces><NetworkInterface name="lo0" multicast="true"/></Interfaces></General><Discovery><ParticipantIndex>none</ParticipantIndex></Discovery></Domain></CycloneDDS>'
```

- `ParticipantIndex none`: Cyclone's default per-process index pool runs out with big launches
  ("Failed to find a free participant index").
- `lo0`: discovery multicast stays on the Mac's loopback. Over Wi-Fi it is lossy, and a
  TurtleBot 4 + Nav2 sim then took anywhere from 20 s to several minutes to come up, or never
  did. With `lo0` it comes up in the same time every run.
- This is for nodes on one Mac. To reach another computer or a robot, remove the
  `<General>...</General>` part.
- Don't combine it with `ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST`: that turns multicast off,
  and with `ParticipantIndex none` nothing is discovered.

### Optional: Add to your shell config

```bash
echo 'source $(brew --prefix)/opt/ros2-jazzy/setup.zsh' >> ~/.zshrc
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

### ❌ Gazebo opens but the 3D view is empty (Jazzy / Kilted)

Old `GZ_*` / `QML2_IMPORT_PATH` exports in `~/.zshrc` override the paths `setup.zsh` sets, so
Gazebo cannot find its Ogre shaders. Delete those lines, open a new terminal and source
`setup.zsh` again. See [Gazebo](#gazebo).

### ❌ bad interpreter: /Library/Frameworks/Python.framework/Versions/3.11/bin/python3: no such file or directory

Python 3.11 from python.org is not installed. Homebrew's `python@3.11` will **not** fix this — install the framework Python from https://www.python.org/downloads/macos/ and follow the [Prerequisites](#prerequisites) section above.

### ❌ catkin_pkg not found

```bash
# python version can change. it should be confirmed from error log
brew unlink python@3.14
```

### ❌ `is already installed, it's just not linked`

**That is expected and correct.** These formulae are **keg-only**: they are
deliberately not symlinked into `/opt/homebrew`.

The release tarball is a full colcon install tree, so it also contains copies of
`protoc`, `protoc-gen-upb`, `check_urdf`, `urdf_to_graphiz`, `binvox2bt`, `gz` and the
`GeographicLib` / `benchmark` headers — all of which belong to other Homebrew formulae.

> ⚠️ **Do not run `brew link --overwrite`.** It hands those shared names to ROS 2
> system-wide. For `protoc` that means every other formula resolves ROS 2's copy, which
> is built against a different `abseil` than the one Homebrew ships and fails to start
> outside a sourced ROS environment:
> ```
> dyld: Library not loaded: .../libabsl_die_if_null.2601.0.0.dylib
> ```
> If you ran it before, undo it once with `brew unlink ros2-humble`.

Nothing needs linking — ROS 2 is reached by sourcing the environment, which works with
`/opt/homebrew/bin` not on `PATH` at all:

```bash
source $(brew --prefix)/opt/ros2-humble/setup.zsh
```

### ❌ `ModuleNotFoundError` / `Failed to load entry point`

These are **Python** modules, not Homebrew formulae — `brew install` will not fix them.
Install the list in [Python dependencies](#python-dependencies-required) into the
python.org 3.11.

### ❌ A missing C/C++ library

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
