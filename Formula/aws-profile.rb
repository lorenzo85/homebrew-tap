class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.4.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.4.0/aws-profile-darwin-arm64.tar.gz"
      sha256 "5602a01511afc51c0422aa19f2507266b8b48a70fd5807610fcd77c643f01691"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.4.0/aws-profile-darwin-amd64.tar.gz"
      sha256 "92e8df46fa317dbabcb1e8cd2f625e74e8dc05af483b8f757ea3085cc1af7210"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.4.0/aws-profile-linux-arm64.tar.gz"
      sha256 "45d5ad8d5ec8d54e5ce124790bf7538b43dca248ecc05ed0c67699ffe185d4e3"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.4.0/aws-profile-linux-amd64.tar.gz"
      sha256 "02719cfe56529becb8af5a5d6f1a701db66a3a6fc701566afd88010679fb1a5b"
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
