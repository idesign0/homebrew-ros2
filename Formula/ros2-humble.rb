class Ros2Humble < Formula
  desc "Pre-built ROS 2 Humble libraries for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"
  # Point to your humble branch
  url "https://github.com/idesign0/homebrew-ros2.git", :branch => "humble"
  version "0.1.0"

  def install
    # This takes everything from your 'humble' branch and puts it in the Cellar
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      To use ROS 2 humble, you must source the setup script:
        source #{opt_prefix}/setup.bash
    EOS
  end
end
