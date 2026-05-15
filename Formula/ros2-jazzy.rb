class Ros2Jazzy < Formula
  desc "ROS 2 Jazzy for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.05.14.40"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/jazzy-#{version}/ros2-jazzy-macos-#{version}.tar.gz"

  sha256 "2736523ab3a5fa85917a5de6b4d388af2eb4b76eaec0ea089de160f93021b7b6"

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
  end

  def caveats
    <<~EOS
      Source ROS 2 environment:
        source #{opt_prefix}/setup.bash
  
      Add the following to your ~/.zshrc (or ~/.bashrc) for Gazebo Sim Setup:
        export GZ_SIM_SYSTEM_PLUGIN_PATH=#{opt_prefix}/lib/gz-sim-8/plugins
        export GZ_SIM_PHYSICS_ENGINE_PATH=#{opt_prefix}/lib/gz-physics-7/engine-plugins
        export GZ_SIM_RESOURCE_PATH=#{opt_prefix}/share/gz/gz-sim8/worlds:#{opt_prefix}/share/gz/gz-sim8/models
        export GZ_GUI_PLUGIN_PATH=#{opt_prefix}/lib/gz-sim-8/plugins/gui:#{opt_prefix}/lib/gz-gui-8/plugins
        export QML2_IMPORT_PATH=#{opt_prefix}/lib/gz-sim-8/plugins/gui
        export GZ_RENDERING_PLUGIN_PATH=#{opt_prefix}/lib/gz-rendering-8/engine-plugins
        export GZ_RENDERING_RESOURCE_PATH=#{opt_prefix}/share/gz/gz-rendering8
    EOS
  end
end
