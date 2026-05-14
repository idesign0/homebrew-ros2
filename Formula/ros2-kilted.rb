class Ros2Kilted < Formula
  desc "ROS 2 Kilted for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.05.14.100"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/kilted-#{version}/ros2-kilted-macos-#{version}.tar.gz"

  sha256 "08cf14fa7db908f0514a496dce0ebaf5df23250167edb4daf98871a56692876e"

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
  depends_on "gflags"
  depends_on "glew"
  depends_on "glog"
  depends_on "gpsd"
  depends_on "graphicsmagick"
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
  depends_on "osrf/simulation/ogre2.3"
  
  def install
      prefix.install Dir["*"]
  end

  def post_install
    ohai "Checking for missing versioned library symlinks..."
    fixed = 0
  
    Dir.glob("#{lib}/**/*.dylib").each do |our_lib|
      Utils.popen_read("otool", "-L", our_lib).each_line do |line|
        dep_path = line.strip.split.first
        # Only care about external Homebrew deps that are missing
        next unless dep_path&.start_with?("#{HOMEBREW_PREFIX}/opt/")
        next if dep_path.start_with?(opt_prefix.to_s)
        next if File.exist?(dep_path)
  
        dep_dir  = Pathname(dep_path).dirname
        dep_name = Pathname(dep_path).basename.to_s
  
        # libjsoncpp.26.dylib → libjsoncpp
        base = dep_name.sub(/(\.\d+)+\.dylib$/, "")
  
        # Find the actual installed dylib (non-symlink)
        actual = dep_dir.glob("#{base}.*.dylib").reject(&:symlink?).first
  
        symlink = dep_dir/dep_name
        next if symlink.exist?
  
        if actual
          symlink.make_symlink(actual)
          ohai "Linked #{dep_name} → #{actual.basename}"
          fixed += 1
        else
          opoo "Cannot fix: #{dep_name} — no matching dylib found in #{dep_dir}"
        end
      end
    end
  
    ohai "Fixed #{fixed} missing symlink(s)." if fixed > 0

    # --- Fix Boost: ensure install names and all references use @rpath ---  
    ohai "Rewriting absolute Boost references in all dylibs..."
    boost_fixed = 0
    boost_patched = []
  
    Dir.glob("#{lib}/**/*.dylib").reject { |f| File.symlink?(f) }.each do |our_lib|
      changed = false
      Utils.popen_read("otool", "-L", our_lib).each_line do |line|
        dep_path = line.strip.split.first
        next unless dep_path&.include?("libboost_")
        next if dep_path.start_with?("@")
  
        basename = File.basename(dep_path)
        next unless File.exist?("#{lib}/#{basename}")
  
        system "install_name_tool", "-change", dep_path, "@rpath/#{basename}", our_lib
        changed = true
        boost_fixed += 1
      end
      if changed
        boost_patched << our_lib unless boost_patched.include?(our_lib)
      end
    end
  
    if boost_fixed > 0
      ohai "Fixed #{boost_fixed} Boost reference(s). Re-signing #{boost_patched.size} library/libraries..."
      boost_patched.each { |f| system "codesign", "--force", "--sign", "-", f }
    end
  end

  def caveats
    <<~EOS
      Source ROS 2 environment:
        source #{opt_prefix}/setup.bash
  
      Add the following to your ~/.zshrc (or ~/.bashrc) for Gazebo Sim Setup:
        export GZ_SIM_SYSTEM_PLUGIN_PATH=#{opt_prefix}/lib/gz-sim-9/plugins
        export GZ_SIM_PHYSICS_ENGINE_PATH=#{opt_prefix}/lib/gz-physics-8/engine-plugins
        export GZ_SIM_RESOURCE_PATH=#{opt_prefix}/share/gz/gz-sim9/worlds:#{opt_prefix}/share/gz/gz-sim9/models
        export GZ_GUI_PLUGIN_PATH=#{opt_prefix}/lib/gz-sim-9/plugins/gui:#{opt_prefix}/lib/gz-gui-9/plugins
        export QML2_IMPORT_PATH=#{opt_prefix}/lib/gz-sim-9/plugins/gui
        export GZ_RENDERING_PLUGIN_PATH=#{opt_prefix}/lib/gz-rendering-9/engine-plugins
        export GZ_RENDERING_RESOURCE_PATH=#{opt_prefix}/share/gz/gz-rendering9
    EOS
  end
end
