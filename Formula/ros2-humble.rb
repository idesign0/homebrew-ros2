class Ros2Humble < Formula
  desc "ROS 2 Humble for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.05.12.144"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/humble-#{version}/ros2-humble-macos-#{version}.tar.gz"

  sha256 "545138ef5a4956f699f2a37ef490cec62c037eae076f62978d254c07cd19626e"

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
