class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.8.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.2/aws-profile-darwin-arm64.tar.gz"
      sha256 "49bdcf526c621d79aed90eb486cf72cbb4efa78870570ebb9c5d8feb65e93e3d"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.2/aws-profile-darwin-amd64.tar.gz"
      sha256 "46993000afb563c30aa5dc9c16cbc72d5daf5cc6186311e5c45ed1604bc19fc9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.2/aws-profile-linux-arm64.tar.gz"
      sha256 "c8d9d902a4ca084956993448d6969b8725be037490a196173d19aafc38c9d33f"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.2/aws-profile-linux-amd64.tar.gz"
      sha256 "2fbd8f250c751194869ddd0f20129f5298a3e75887639a5b1ee1363756ddbb2f"
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
