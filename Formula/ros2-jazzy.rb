class Ros2Jazzy < Formula
  desc "Pre-built ROS 2 Jazzy libraries for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"
  version "0.1.0"

  def install
    system "git", "clone", "--branch", "jazzy",
           "https://github.com/idesign0/homebrew-ros2.git", buildpath/"ros2"
    cd buildpath/"ros2" do
      system "git", "lfs", "pull"
    end
    prefix.install Dir[buildpath/"ros2/*"]
  end

  def caveats
    <<~EOS
      To use ROS 2 Jazzy, you must source the setup script:
        source #{opt_prefix}/setup.bash
    EOS
  end
end
