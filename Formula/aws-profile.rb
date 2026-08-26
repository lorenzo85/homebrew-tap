class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.8.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.7/aws-profile-darwin-arm64.tar.gz"
      sha256 "b8d6f4e2a7b6a8d9a9bf9feaa18c5f1241b52507a4f73ae9d061d90775d1d7b3"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.7/aws-profile-darwin-amd64.tar.gz"
      sha256 "74eb0fdd2a996726f1532ba01948562d024da4de39ae5d0cf57e24d0ab0af746"
    end
  end

  depends_on "fzf"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.7/aws-profile-linux-arm64.tar.gz"
      sha256 "6175dffedc02cce37dc3202f4af7882683e822d5bfd95761f472abca813f305e"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.7/aws-profile-linux-amd64.tar.gz"
      sha256 "b552fafdbba621840c759836fd4a9d779d238c97369ab172bb294ea24348e314"
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
      To use the awsp interactive profile switcher in zsh, run once:
        echo 'source #{opt_share}/zsh/site-functions/_awsp' >> ~/.zshrc

      Then reload your shell or run:
        source ~/.zshrc

      Fish shell loads awsp automatically — no extra steps needed.
    EOS
  end

  test do
    output = shell_output("#{bin}/aws-profile --version").strip
    assert_match version.to_s, output
  end
end
