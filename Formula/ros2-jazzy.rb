class Ros2Jazzy < Formula
  desc "ROS 2 Jazzy for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.05.12.35"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/jazzy-#{version}/ros2-jazzy-macos-#{version}.tar.gz"

  sha256 "b4bbe5f01814f9ffceea39c2b1c0d008ae57f62e25e0971f5f161fbbccac1f68"

  def install
      prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      source #{opt_prefix}/setup.bash
    EOS
  end
end
