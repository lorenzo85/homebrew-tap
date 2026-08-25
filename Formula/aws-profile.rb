class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.3.0/aws-profile-darwin-arm64.tar.gz"
      sha256 "26b867a17d9c4520e66359af1b2c1eea2772639b284eb69feff5b67af9db7e80"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.3.0/aws-profile-darwin-amd64.tar.gz"
      sha256 "4a553f78d2d7a36ed7e30e27f06a6192139bad9e61e5305dcc514c2a34a9a4fc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.3.0/aws-profile-linux-arm64.tar.gz"
      sha256 "fcfd7e161f481a0451187aa45fe953ee443ec7473c0cac15b5cad8649f2131b5"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.3.0/aws-profile-linux-amd64.tar.gz"
      sha256 "6c80eadb40bb7a7151cfe427060b55b77eb98cebcc212f19f8d590d4eeab00e5"
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
