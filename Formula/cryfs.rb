class Cryfs < Formula
  desc "Cryptographic filesystem for the cloud"
  homepage "https://www.cryfs.org/"
  url "https://github.com/cryfs/cryfs/archive/0.9.3.tar.gz"
  sha256 "124ac3315161c702eef4ba2e5720a39b7ab8f012aefd9313578373c2150a62f0"

  head "https://github.com/cryfs/cryfs.git", :branch => "develop"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "cryptopp"
  depends_on "openssl"
  depends_on :osxfuse

  def install
    mkdir "cmake" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    require "open3"
    Open3.popen3({ "CRYFS_FRONTEND" => "noninteractive" }, "#{bin}/cryfs", "basedir", "mountdir") do |stdin, stdout, _|
      stdin.write("password")
      stdin.close
      assert_match(/^CryFS Version 0\.9\.3/, stdout.read)
    end
  end
end
