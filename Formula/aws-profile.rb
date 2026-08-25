class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.8.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.0/aws-profile-darwin-arm64.tar.gz"
      sha256 "1435a52337a0026b7b719bd67686fc57ffe32a29a695f2213c09db1bc597ba50"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.0/aws-profile-darwin-amd64.tar.gz"
      sha256 "8918caf8bcb14ef2f159f1f7be2996ae4bf85dbd1909d488b07d2e4e9fbf23ff"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.0/aws-profile-linux-arm64.tar.gz"
      sha256 "1c4bec768b215f6f0397a897f3d89fd5617d45238fb1b9897d888a6691fd69dc"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.0/aws-profile-linux-amd64.tar.gz"
      sha256 "97322f39acc98b6012440cdf596c04887b19682147a945652b8dbe2ed534af80"
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
