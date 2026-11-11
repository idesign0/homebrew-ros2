class Ros2Kilted < Formula
  desc "ROS 2 Kilted for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.11.11.11"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/kilted-#{version}/ros2-kilted-macos-#{version}.tar.gz"

  sha256 "2c206891e5bbbaf0885233f238bd3faa73073d5cc6141eb277efa57aa13191b4"

  # Deliberately NOT linked into HOMEBREW_PREFIX.
  #
  # The release tarball is a whole colcon install tree, so `prefix.install Dir["*"]`
  # also ships copies of programs and headers that our OWN declared dependencies
  # provide. Linking the keg makes those copies win the shared names:
  #   bin/protoc, bin/protoc-gen-upb      <- protobuf
  #   bin/check_urdf, bin/urdf_to_graphiz <- urdfdom
  #   bin/binvox2bt                       <- octomap
  #   bin/gz                              <- gz-tools
  #   include/GeographicLib/*             <- geographiclib
  #   include/benchmark/*                 <- google-benchmark
  # On a machine where `brew link --overwrite` had been run, 81 entries in
  # /opt/homebrew/bin pointed into this keg, and `protoc` could not even start
  # outside a sourced ROS environment:
  #   dyld: Library not loaded: .../libabsl_die_if_null.2601.0.0.dylib
  # because it was built against a different abseil soname than the one brew ships.
  # Reported in idesign0/ros2_macOS#8.
  #
  # Nothing is lost by not linking. setup.zsh resolves its own location
  # (COLCON_CURRENT_PREFIX) and prepends this keg's bin to PATH along with
  # AMENT_PREFIX_PATH, PYTHONPATH and the library paths, so `ros2` works with
  # /opt/homebrew/bin absent from PATH entirely. Homebrew still creates
  # opt/<name> for keg-only formulae, which is what setup.zsh and the GZ_* exports
  # below reference. The `ros2` symlink that linking provided did not even function
  # without sourcing -- it failed in importlib.
  keg_only "it ships copies of files its own dependencies also provide " \
           "(protoc, check_urdf, binvox2bt, gz, GeographicLib and benchmark " \
           "headers), and ROS 2 is used by sourcing setup.zsh rather than by linking"

  # No Homebrew formulae at RUN time: every library the tree links, and every Qt plugin
  # and QML module it dlopens, ships inside the keg under vendor/ (ci/deploy/package_tree.py
  # in idesign0/ros2_macOS). Verified by its package-smoke workflow: 0 Homebrew formulae
  # load at run time, gz physics steps, ros_gz_bridge relays, rviz2's Qt comes from vendor/.
  # The 57 depends_on this used to carry were the BUILD machine's link set; installing them
  # only added a second copy of Qt, VTK, OpenCV, PCL... that nothing in the keg loads.
  depends_on arch: :arm64

  # The console scripts hard-code this interpreter in their shebang (26 of them in the
  # jazzy keg), so if it is absent the failure surfaces much later and cryptically:
  #   zsh: .../bin/ros2: bad interpreter:
  #        /Library/Frameworks/Python.framework/Versions/3.11/bin/python3: no such file
  # Homebrew's python@3.11 is NOT a substitute -- it lives elsewhere and these binaries
  # were built against the python.org framework build. Reported in idesign0/ros2_macOS#8.
  FRAMEWORK_PYTHON = "/Library/Frameworks/Python.framework/Versions/3.11/bin/python3"

  def install
      prefix.install Dir["*"]
  end

  def post_install
    # A warning, not a failure: the files are installed correctly either way, and the
    # user can satisfy this afterwards without reinstalling.
    unless File.exist?(FRAMEWORK_PYTHON)
      opoo <<~MSG
        Python 3.11 from python.org was not found at
          #{FRAMEWORK_PYTHON}
        The ros2 CLI will fail with "bad interpreter" until it is installed. Get the
        macOS 64-bit universal2 installer from https://www.python.org/downloads/macos/
        and run Install Certificates.command afterwards.
        Homebrew's python@3.11 will not work -- see the tap README.
      MSG
    end
  end

  def caveats
    <<~EOS
      This formula is keg-only, so it is not symlinked into #{HOMEBREW_PREFIX}.
      That is expected -- do NOT run `brew link --overwrite`; it would hand
      protoc, check_urdf, binvox2bt and gz to this keg system-wide.
      If you linked it previously, undo that once with:
        brew unlink #{name}

      Source ROS 2 environment:
        source #{opt_prefix}/setup.zsh

      colcon argcomplete (must come after ROS source, needs bashcompinit for zsh)
        autoload bashcompinit && bashcompinit
        eval "$(register-python-argcomplete colcon)"

      Gazebo needs no extra exports: setup.zsh sets the plugin, resource and install-prefix
      paths for the gz copy inside this keg. Exports from older caveats (GZ_SIM_*_PATH,
      GZ_CONFIG_PATH, QML2_IMPORT_PATH, ...) point at a second gz copy -- remove them.

      Building your own packages against this keg needs the usual build tools
      (brew install cmake ninja pkgconf) and whatever headers find_package() reports
      missing; nothing is needed just to run ROS 2.

      Required Python dependencies (install once, into the python.org 3.11):
      pip3.11 install empy==3.3.4 lark==1.1.1 catkin_pkg netifaces osrf-pycommon PyYAML packaging psutil typeguard jinja2 lxml numpy
    EOS
  end
end
