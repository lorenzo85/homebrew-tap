class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.7.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.7.0/aws-profile-darwin-arm64.tar.gz"
      sha256 "f5adb0b1d0c25aa8d86e4ab4d01eb84978ec3d1b652156662eb75f1ba7bae5b7"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.7.0/aws-profile-darwin-amd64.tar.gz"
      sha256 "cfd15f38856277a2cf0c934245cac4237cf492b7188b7d4f9170e5a93b4d35d1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.7.0/aws-profile-linux-arm64.tar.gz"
      sha256 "c87eccdd2816a52cabbd2bde1cbad2545e61fc0adf4e5fc09baab9e51ac04eab"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.7.0/aws-profile-linux-amd64.tar.gz"
      sha256 "c5634026dd1e1f2a77613b822348d36cabb9319028afa80c2d9125e5374ec385"
    end
  end

  def install
    bin.install "aws-profile"
  end

  test do
    output = shell_output("#{bin}/aws-profile --version").strip
    assert_match version.to_s, output
  end
end
