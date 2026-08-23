class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.1.0/aws-profile-darwin-arm64.tar.gz"
      sha256 "0a7dc8c82b02c1678d10ca72d3d36f27b73efbe0a4d997641b30628e66d05772"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.1.0/aws-profile-darwin-amd64.tar.gz"
      sha256 "34f7e3f44c938d7b3e67aa8dd257ae493a980ccfa669b272c5abd7bf87bf6aae"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.1.0/aws-profile-linux-arm64.tar.gz"
      sha256 "25ca8520785addd50e6f60c7183b0fdedb21a5be3ad57f50782717502b7afd60"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.1.0/aws-profile-linux-amd64.tar.gz"
      sha256 "c4e9e9510d57c5cf232d9699907142c9c2ca7d90a056dc3d282f17ef00c02fca"
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
