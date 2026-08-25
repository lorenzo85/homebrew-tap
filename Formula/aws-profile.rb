class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.6.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.6.0/aws-profile-darwin-arm64.tar.gz"
      sha256 "07d47e9ad6159beed653fdc30232a55fba2802732cb2f2efb890bf3b970192aa"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.6.0/aws-profile-darwin-amd64.tar.gz"
      sha256 "2a3268d85b3d018960d014c659044228047d2ae82ed6236ff7f47fcc8c68232b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.6.0/aws-profile-linux-arm64.tar.gz"
      sha256 "1733a589725c8c54dcf802ba86ec34fdd9e39b1f9feeba7b0b9acb32b70cf526"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.6.0/aws-profile-linux-amd64.tar.gz"
      sha256 "53f8088d28d8b61e737c7717558296e72cd12c80b787e87efc35ceaa3ab203e8"
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
