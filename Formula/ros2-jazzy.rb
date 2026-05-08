class Ros2Jazzy < Formula
  desc "Pre-built ROS 2 Jazzy libraries for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"
  version "0.1.0"

  head do
    url "https://github.com/idesign0/homebrew-ros2.git", branch: "jazzy"
  end

  def install
    system "git", "lfs", "pull"
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      To use ROS 2 Jazzy, you must source the setup script:
        source #{opt_prefix}/setup.bash
    EOS
  end
end
