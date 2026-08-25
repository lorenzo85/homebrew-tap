class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.8.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.4/aws-profile-darwin-arm64.tar.gz"
      sha256 "28f375a727a757bb3456ee2d61faa757b674d81f82564568c3a54d45663a3b92"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.4/aws-profile-darwin-amd64.tar.gz"
      sha256 "b67a092b2067d3e202ff4b2d318689bf9080227e78cbac369b1a2a44284b0406"
    end
  end

  depends_on "fzf"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.4/aws-profile-linux-arm64.tar.gz"
      sha256 "129596744b3d67875ac7176b9cea14799791ad5886c038e970993dcb8914c64a"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.4/aws-profile-linux-amd64.tar.gz"
      sha256 "8e489965d1139c4d6a3c3759e0fc3dd9ff8e273f8d7193002b9af680d7039bc5"
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

  test do
    output = shell_output("#{bin}/aws-profile --version").strip
    assert_match version.to_s, output
  end
end
