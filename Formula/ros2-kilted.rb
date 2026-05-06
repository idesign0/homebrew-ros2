class Ros2Kilted < Formula
  desc "Pre-built ROS 2 Kilted libraries for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"
  # Point to your kilted branch
  url "https://github.com/idesign0/homebrew-ros2.git", :branch => "kilted"
  version "0.1.0"

  def install
    # This takes everything from your 'kilted' branch and puts it in the Cellar
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      To use ROS 2 Kilted, you must source the setup script:
        source #{opt_prefix}/setup.bash
    EOS
  end
end
