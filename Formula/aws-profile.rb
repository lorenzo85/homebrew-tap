class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.9.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.0/aws-profile-darwin-arm64.tar.gz"
      sha256 "11d331bbe92f507ccdb17c97bd8785334a9765659ec379908ec7ffb29932343d"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.0/aws-profile-darwin-amd64.tar.gz"
      sha256 "ddca92c96963840f6d672ebf303580bcea5d0bb29e479006b033e4efb3fdd190"
    end
  end

  depends_on "fzf"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.0/aws-profile-linux-arm64.tar.gz"
      sha256 "1d20ef633799f0657bf550a891820632000a975a2beecb4dea376403f767e2b9"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.0/aws-profile-linux-amd64.tar.gz"
      sha256 "f36daff72def245eae9659dd23aebf408e2f68a6ee8f5a8e251915be3efbf4e4"
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
        set start_url (aws configure get sso_start_url --profile $account 2>/dev/null)
        if not python3 -c "import json,glob,os,sys; from datetime import datetime,timezone; m=next((d for f in glob.glob(os.path.expanduser('~/.aws/sso/cache/*.json')) for d in [json.load(open(f))] if d.get('startUrl')==sys.argv[1] and d.get('accessToken')),None); sys.exit(0 if m and datetime.fromisoformat(m['expiresAt'].replace('Z','+00:00'))>datetime.now(timezone.utc) else 1)" $start_url 2>/dev/null
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
        local account start_url elevated
        account=$(aws-profile list | fzf --prompt="AWS account: " --height=~40%) || return
        start_url=$(aws configure get sso_start_url --profile "$account" 2>/dev/null)
        if ! python3 -c "import json,glob,os,sys; from datetime import datetime,timezone; m=next((d for f in glob.glob(os.path.expanduser('~/.aws/sso/cache/*.json')) for d in [json.load(open(f))] if d.get('startUrl')==sys.argv[1] and d.get('accessToken')),None); sys.exit(0 if m and datetime.fromisoformat(m['expiresAt'].replace('Z','+00:00'))>datetime.now(timezone.utc) else 1)" "$start_url" 2>/dev/null; then
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
