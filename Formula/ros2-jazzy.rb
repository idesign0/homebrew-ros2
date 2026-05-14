class Ros2Jazzy < Formula
  desc "ROS 2 Jazzy for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.05.12.37"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/jazzy-#{version}/ros2-jazzy-macos-#{version}.tar.gz"

  sha256 "5a70f12006e796297107ee29971e5e09dce8ea9342178c506ccdd9cf6333df12"

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
