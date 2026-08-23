class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.1.0/aws-profile-darwin-arm64.tar.gz"
      sha256 "8d1ea05c75f011fb0fef5ebfca7e99acd9bd51def65a5cfa5d8cc3775fc1e496"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.1.0/aws-profile-darwin-amd64.tar.gz"
      sha256 "2984bc10450b22a0e96bef8a209c004829752717a815aba73860ccd460b5cffc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.1.0/aws-profile-linux-arm64.tar.gz"
      sha256 "734c4614093f9caa99a021961ae5182240faa155ffb9baaa02faa802d8d7edb2"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.1.0/aws-profile-linux-amd64.tar.gz"
      sha256 "b7fa64b952280eacb91d62f4c0db0f150a7c4d768371265ad3bcfe40f94888c1"
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
