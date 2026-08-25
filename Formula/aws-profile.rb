class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.8.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.1/aws-profile-darwin-arm64.tar.gz"
      sha256 "e8a1ebf58d2000deda5bf376a8b7c5e6f29f7f7eea92ef09115d62c8b1ed6a34"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.1/aws-profile-darwin-amd64.tar.gz"
      sha256 "1dea7646d7b436439ee2f56a0eae1723ff42d27734f959e399d7c21c82753c03"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.1/aws-profile-linux-arm64.tar.gz"
      sha256 "25c3c5b581dc07ce4a0ba1165b3264ee287d1b429004263266b1ba037cca6677"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.1/aws-profile-linux-amd64.tar.gz"
      sha256 "cc74ed50171065245eea6acf8b35e24058f502bcf5d3e4956f75408fd96c7ca6"
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
