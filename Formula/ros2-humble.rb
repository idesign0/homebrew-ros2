class Ros2Humble < Formula
  desc "ROS 2 Humble for macOS"
  homepage "https://github.com/idesign0/homebrew-ros2"

  version "26.05.12.144"

  url "https://github.com/idesign0/homebrew-ros2/releases/download/humble-#{version}/ros2-humble-macos-#{version}.tar.gz"

  sha256 "545138ef5a4956f699f2a37ef490cec62c037eae076f62978d254c07cd19626e"

  depends_on "abseil"
  depends_on "assimp"
  depends_on "bullet"
  depends_on "console_bridge"
  depends_on "dartsim"
  depends_on "fcl"
  depends_on "ffmpeg"
  depends_on "flann"
  depends_on "fmt"
  depends_on "freeglut"
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "gdal"
  depends_on "gettext"
  depends_on "gflags"
  depends_on "glew"
  depends_on "glib"
  depends_on "glog"
  depends_on "gpsd"
  depends_on "graphicsmagick"
  depends_on "gts"
  depends_on "jsoncpp"
  depends_on "libccd"
  depends_on "libomp"
  depends_on "libpng"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on "lz4"
  depends_on "mesa"
  depends_on "metis"
  depends_on "octomap"
  depends_on "ode"
  depends_on "osrf/simulation/ogre1.9"
  depends_on "osrf/simulation/ogre2.3"
  depends_on "ompl"
  depends_on "opencv"
  depends_on "openssl@3"
  depends_on "openvdb"
  depends_on "pcl"
  depends_on "qhull"
  depends_on "qt@5"
  depends_on "qtbase"
  depends_on "spdlog"
  depends_on "suite-sparse"
  depends_on "tbb"
  depends_on "tinyxml2"
  depends_on "urdfdom"
  depends_on "vtk"
  depends_on "zeromq"
  depends_on "zstd"
  
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
