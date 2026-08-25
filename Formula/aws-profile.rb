class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.5.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.5.0/aws-profile-darwin-arm64.tar.gz"
      sha256 "2e55520084655e82e37754cb8eda9b048fa10d26998e93563822c03cf818dc38"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.5.0/aws-profile-darwin-amd64.tar.gz"
      sha256 "66398989919ce18e50d6b7ea8570f3c2f43b641dbbb72318f8ed82e01aea4561"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.5.0/aws-profile-linux-arm64.tar.gz"
      sha256 "748e87c32f860b5a31fb0bb70788149d61075ae1159e7ff420b91434068dddbd"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.5.0/aws-profile-linux-amd64.tar.gz"
      sha256 "96945b40f0cb737e7b8d7975559837a918011bc53b26312d1e172322919d65ec"
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
