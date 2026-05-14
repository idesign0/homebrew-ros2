class Ros2Kilted < Formula
  desc "ROS 2 Kilted for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.05.14.99"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/kilted-#{version}/ros2-kilted-macos-#{version}.tar.gz"

  sha256 "9689f8579588ba7af3816d75340030838c3e3f7f74a3f53b5c181f0cefee50e3"

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
