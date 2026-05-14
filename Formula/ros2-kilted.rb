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
    # jsoncpp ABI compat: build used .26, Homebrew ships .27+
    jsoncpp_lib = Formula["jsoncpp"].opt_lib
    symlink_26 = jsoncpp_lib/"libjsoncpp.26.dylib"
    unless symlink_26.exist?
      actual = jsoncpp_lib.glob("libjsoncpp.*.dylib").reject { |f| f.symlink? }.first
      symlink_26.make_symlink(actual) if actual
    end
  end
  
  def caveats
    <<~EOS
      source #{opt_prefix}/setup.bash
    EOS
  end
end
