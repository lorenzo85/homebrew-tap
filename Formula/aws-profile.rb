class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.8.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.6/aws-profile-darwin-arm64.tar.gz"
      sha256 "ee028a75e7024a0a0497969b78061a814e52e9a124446de7a9faa30ea1ec993d"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.6/aws-profile-darwin-amd64.tar.gz"
      sha256 "13b1f75a26757f0aee524969344bfd7b81519e857d0975c4e3c6b976fdc09dd5"
    end
  end

  depends_on "fzf"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.6/aws-profile-linux-arm64.tar.gz"
      sha256 "584226dcd3083081e6d9f2411ba03bfba6c788114597bfb063b4dad41e5407a4"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.6/aws-profile-linux-amd64.tar.gz"
      sha256 "8023462ed104da547dad4392972bb170650cc6c8a518d2f7fb0bc6379a11f164"
    end
  end

  def install
    bin.install "aws-profile"

    # Fish function
    (share/"fish/vendor_functions.d").mkpath
    (share/"fish/vendor_functions.d/awsp.fish").write <<~FISH
      function awsp --description 'Interactively select an AWS profile'
        set account (aws-profile list | fzf --prompt="AWS account: " --height=~40%)
        test -n "$account" || return
        if not aws sts get-caller-identity --profile $account &>/dev/null
          aws sso login --profile $account
        end
        read -l -P "Elevated access? [y/N] " elevated
        if test "$elevated" = y -o "$elevated" = Y
          aws-profile $account+
        else
          aws-profile $account
        end
      end
    FISH

    # Zsh/Bash function
    (share/"zsh/site-functions").mkpath
    (share/"zsh/site-functions/_awsp").write <<~ZSH
      awsp() {
        local account
        account=$(aws-profile list | fzf --prompt="AWS account: " --height=~40%) || return
        if ! aws sts get-caller-identity --profile "$account" &>/dev/null; then
          aws sso login --profile "$account"
        fi
        read "elevated?Elevated access? [y/N] "
        if [[ "$elevated" =~ ^[Yy]$ ]]; then
          aws-profile "${account}+"
        else
          aws-profile "$account"
        fi
      }
    ZSH
  end

  def caveats
    <<~EOS
      To use the awsp interactive profile switcher in zsh, add to ~/.zshrc:
        source #{opt_share}/zsh/site-functions/_awsp

      Fish shell loads awsp automatically — no extra steps needed.
    EOS
  end

  test do
    output = shell_output("#{bin}/aws-profile --version").strip
    assert_match version.to_s, output
  end
end
