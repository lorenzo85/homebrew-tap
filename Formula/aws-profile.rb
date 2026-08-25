class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.8.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.5/aws-profile-darwin-arm64.tar.gz"
      sha256 "f19188f7ceee704398b8d462590d28bf1bfc38034a20ab3f4a2aa1327a9583df"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.5/aws-profile-darwin-amd64.tar.gz"
      sha256 "1ca8c259841d1913ed96c827a62900e26cd87fb5a7eaebcd5f554700eb425402"
    end
  end

  depends_on "fzf"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.5/aws-profile-linux-arm64.tar.gz"
      sha256 "997330174d119879dd2da44b57c13548e5627fc98e43bec352303d883aef0a1c"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.5/aws-profile-linux-amd64.tar.gz"
      sha256 "88588c9c558a9f14ad0ae2188b1bc26d30cac04c388295d0e4235df9e6cd59df"
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
        read -r -p "Elevated access? [y/N] " elevated
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
