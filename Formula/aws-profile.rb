class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.8.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.3/aws-profile-darwin-arm64.tar.gz"
      sha256 "fa4bc4f8e2635c669c5dba2cb0a9f61114eef62386a966151fcaa3fa09db7c06"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.3/aws-profile-darwin-amd64.tar.gz"
      sha256 "a547c8fc2dda306a00b3838f1a5991ce84162335d5706fc28e307f60a64b14ff"
    end
  end

  depends_on "fzf"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.3/aws-profile-linux-arm64.tar.gz"
      sha256 "e9fd144816ffbc3259181501784e835215c701bbdbd465b6840c0fd9b6c7ec23"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.3/aws-profile-linux-amd64.tar.gz"
      sha256 "e9cbc2ffa28d579e1dddcc94960532744e258e067d22c356def3e40498c8fc15"
    end
  end

  def install
    bin.install "aws-profile"

    # Fish function
    (share/"fish/vendor_functions.d").mkpath
    (share/"fish/vendor_functions.d/awsp.fish").write <<~FISH
      function awsp --description 'Interactively select an AWS profile'
        set account (aws-profile list | fzf --prompt="AWS account: " --height=40%)
        test -n "" || return
        read -l -P "Elevated access? [y/N] " elevated
        if test "" = y -o "" = Y
          aws-profile +
        else
          aws-profile 
        end
      end
    FISH

    # Zsh/Bash function
    (share/"zsh/site-functions").mkpath
    (share/"zsh/site-functions/_awsp").write <<~ZSH
      awsp() {
        local account
        account= || return
        read -r -p "Elevated access? [y/N] " elevated
        if [[ "" =~ ^[Yy]$ ]]; then
          aws-profile "+"
        else
          aws-profile ""
        fi
      }
    ZSH
  end

  test do
    output = shell_output("#{bin}/aws-profile --version").strip
    assert_match version.to_s, output
  end
end
