class Ros2Jazzy < Formula
  desc "ROS 2 Jazzy for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.05.11.1"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/jazzy-#{version}/ros2-jazzy-macos-#{version}.tar.gz"

  sha256 "REPLACE_SHA"

  def install
    prefix.install Dir["install/*"]
  end

  def caveats
    <<~EOS
      source #{opt_prefix}/setup.bash
    EOS
  end
end
