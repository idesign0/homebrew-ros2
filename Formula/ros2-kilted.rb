class Ros2Kilted < Formula
  desc "ROS 2 Kilted for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.05.12.97"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/kilted-#{version}/ros2-kilted-macos-#{version}.tar.gz"

  sha256 "ace3337c25391d2ef68e98783f12773821f7479f0066b00bfc9e3e39db50e279"

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
  
  def caveats
    <<~EOS
      source #{opt_prefix}/setup.bash
    EOS
  end
end
