class Ros2Jazzy < Formula
  desc "Pre-built ROS 2 Jazzy libraries for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"
  # Point to your jazzy branch
  url "https://github.com/idesign0/homebrew-ros2.git", :branch => "jazzy"
  version "0.1.0"

  def install
    # This takes everything from your 'jazzy' branch and puts it in the Cellar
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      To use ROS 2 Jazzy, you must source the setup script:
        source #{opt_prefix}/setup.bash
    EOS
  end
end
