class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.2.0/aws-profile-darwin-arm64.tar.gz"
      sha256 "ef040ba01ae854e276dd77278f33945a80003555933891156a8803ea14100b94"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.2.0/aws-profile-darwin-amd64.tar.gz"
      sha256 "b11b3a542893707520d6e5c8be2a4fb7705ef5489a418efe21aaa11bb7792954"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.2.0/aws-profile-linux-arm64.tar.gz"
      sha256 "6b342ad2a7b1cb83828706fbc0113c0240943dd0be551acff32b416c35b9b355"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.2.0/aws-profile-linux-amd64.tar.gz"
      sha256 "014c73f3e14caeb68ba8504c3d51822e37b59ae0bb81f9dfbfe8f89ad3961ab0"
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
