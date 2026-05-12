class Ros2Kilted < Formula
  desc "ROS 2 Kilted for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.05.11.93"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/kilted-#{version}/ros2-kilted-macos-#{version}.tar.gz"

  sha256 "4718539e6b55a51cf04a9b61992559df922eed03d7c4dd39f06c3d6eb5dc201c"

  def install
      prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      source #{opt_prefix}/setup.bash
    EOS
  end
end
