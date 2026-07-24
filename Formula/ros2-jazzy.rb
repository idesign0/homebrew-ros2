class Ros2Jazzy < Formula
  desc "ROS 2 Jazzy for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.07.24.93"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/jazzy-#{version}/ros2-jazzy-macos-#{version}.tar.gz"

  sha256 "b794f51427db05c94ede0b6159161355170be7282c78680495c75ba176325ce0"

  depends_on "abseil"
  depends_on "assimp"
  depends_on "bullet"
  depends_on "c-blosc"
  depends_on "coal"
  depends_on "console_bridge"
  depends_on "dartsim"
  depends_on "fcl"
  depends_on "ffmpeg"
  depends_on "flann"
  depends_on "fmt"
  depends_on "freeglut"
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "gdal"
  depends_on "geographiclib"
  depends_on "gettext"
  depends_on "gflags"
  depends_on "glew"
  depends_on "glib"
  depends_on "glog"
  depends_on "gpsd"
  depends_on "graphicsmagick"
  depends_on "gts"
  depends_on "ipopt"
  depends_on "jsoncpp"
  depends_on "libccd"
  depends_on "libomp"
  depends_on "libpng"
  depends_on "libx11"
  depends_on "libxi"
  depends_on "libxrandr"
  depends_on "libxxf86vm"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on "libzzip"
  depends_on "lz4"
  depends_on "mesa"
  depends_on "metis"
  depends_on "nlopt"
  depends_on "octomap"
  depends_on "ode"
  depends_on "ompl"
  depends_on "opencv"
  depends_on "openssl@3"
  depends_on "openvdb"
  depends_on "pcl"
  depends_on "pinocchio"
  depends_on "qhull"
  depends_on "qt@5"
  depends_on "qtbase"
  depends_on "spdlog"
  depends_on "suite-sparse"
  depends_on "tbb"
  depends_on "tinyxml2"
  depends_on "urdfdom"
  depends_on "vtk"
  depends_on "zeromq"
  depends_on "zstd"
  depends_on "osrf/simulation/ogre1.9"
  depends_on "osrf/simulation/ogre2.3"

  def install
      prefix.install Dir["*"]
  end
  
  def post_install
    ohai "Checking for stale versioned library references..."
    fixed = 0
    patched = []

    Dir.glob("#{lib}/**/*.dylib").reject { |f| File.symlink?(f) }.each do |our_lib|
      Utils.popen_read("otool", "-L", our_lib).each_line do |line|
        dep_path = line.strip.split.first
        next unless dep_path&.start_with?("#{HOMEBREW_PREFIX}/opt/")
        next if dep_path.start_with?(opt_prefix.to_s)
        next if File.exist?(dep_path)

        dep_dir  = Pathname(dep_path).dirname
        dep_name = Pathname(dep_path).basename.to_s
        base     = dep_name.sub(/(\.\d+)+\.dylib$/, "")

        actual = dep_dir.glob("#{base}.*.dylib").reject(&:symlink?).first
        next unless actual

        system "install_name_tool", "-change", dep_path, actual.to_s, our_lib
        patched << our_lib unless patched.include?(our_lib)
        ohai "Fixed: #{dep_name} → #{actual.basename} in #{File.basename(our_lib)}"
        fixed += 1
      end
    end

    if fixed > 0
      ohai "Fixed #{fixed} stale reference(s). Re-signing #{patched.size} patched library/libraries..."
      patched.each do |f|
        system "codesign", "--force", "--sign", "-", f
      end
    end

    # Add absolute RPATHs for vendor libs to fix dlopen security policy issue.
    # macOS Hardened Runtime blocks @loader_path expansion for plugins loaded via dlopen.
    ohai "Adding absolute vendor lib RPATHs for dlopen compatibility..."
    vendor_fixed = 0
    
    Dir.glob("#{opt_prefix}/opt/**/lib").select { |d| File.directory?(d) }.each do |vendor_dir|
      vendor_libs = Dir.glob("#{vendor_dir}/*.dylib").map { |f| File.basename(f) }
      next if vendor_libs.empty?
    
      Dir.glob("#{lib}/**/*.{dylib,so}").reject { |f| File.symlink?(f) }.each do |our_lib|
        refs = Utils.popen_read("otool", "-L", our_lib).lines.map { |l| l.strip.split.first }
        next unless refs.any? { |r| r&.start_with?("@rpath/") && vendor_libs.include?(File.basename(r.to_s)) }
    
        existing = Utils.popen_read("otool", "-l", our_lib).scan(/path (.+) \(offset/).flatten
        next if existing.include?(vendor_dir)
    
        system "install_name_tool", "-add_rpath", vendor_dir, our_lib
        system "codesign", "--force", "--sign", "-", our_lib
        vendor_fixed += 1
      end
    end

    ohai "Added absolute vendor RPATHs to #{vendor_fixed} library/libraries." if vendor_fixed > 0
  end

  def caveats
    <<~EOS
      Source ROS 2 environment:
        source #{opt_prefix}/setup.zsh

      colcon argcomplete (must come after ROS source, needs bashcompinit for zsh)
        autoload bashcompinit && bashcompinit
        eval "$(register-python-argcomplete colcon)"
  
      Add the following to your ~/.zshrc (or ~/.bashrc) for Gazebo Sim Setup:
        export GZ_CONFIG_PATH=$(brew --prefix ros2-jazzy)/share/gz                                                    
        export GZ_SIM_SYSTEM_PLUGIN_PATH=$(brew --prefix ros2-jazzy)/lib/gz-sim-8/plugins:$(brew --prefix ros2-jazzy)/lib
        export GZ_SIM_PHYSICS_ENGINE_PATH=$(brew --prefix ros2-jazzy)/lib/gz-physics-7/engine-plugins
        export GZ_SIM_RESOURCE_PATH=$(brew --prefix ros2-jazzy)/share/gz/gz-sim8/worlds
        export GZ_GUI_PLUGIN_PATH=$(brew --prefix ros2-jazzy)/lib/gz-sim-8/plugins/gui:$(brew --prefix ros2-jazzy)/lib/gz-gui-8/plugins
        export QML2_IMPORT_PATH=$(brew --prefix ros2-jazzy)/lib/gz-sim-8/plugins/gui
        export GZ_RENDERING_PLUGIN_PATH=$(brew --prefix ros2-jazzy)/lib/gz-rendering-8/engine-plugins
        export GZ_RENDERING_RESOURCE_PATH=$(brew --prefix ros2-jazzy)/share/gz/gz-rendering8
    EOS
  end
end
