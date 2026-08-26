class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.8.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.8/aws-profile-darwin-arm64.tar.gz"
      sha256 "3d952dd394dc9b87f7053c1626af4ec42c99680968431f5765c19c3484b5fe41"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.8/aws-profile-darwin-amd64.tar.gz"
      sha256 "4a156a9929f54b01adca63397672003776f443eeb57eb0bf2e5d1440a7076537"
    end
  end

  depends_on "fzf"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.8/aws-profile-linux-arm64.tar.gz"
      sha256 "0d87cbd0ba2c9652c8298c795c44a1d23bb2c53b3f1ae2c7e2c2458776e50bdc"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.8.8/aws-profile-linux-amd64.tar.gz"
      sha256 "a231cf86757915593c081ef3713cb8f8bf7ef8732125e58f16dd6d902a704f6d"
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
        set session (aws configure get sso_session --profile $account 2>/dev/null)
        if test -z "$session"
          set session (aws configure get sso_start_url --profile $account 2>/dev/null)
        end
        if test -n "$session"
          set key (printf "%s" $session | shasum -a 1 | awk '{print }')
          set cache $HOME/.aws/sso/cache/$key.json
          if not test -f $cache; or not python3 -c "import json,sys,datetime as dt; d=json.load(open(sys.argv[1])); e=dt.datetime.fromisoformat(d['expiresAt'].replace('Z','+00:00')); sys.exit(0 if e>dt.datetime.now(dt.timezone.utc) else 1)" $cache 2>/dev/null
            aws sso login --profile $account
          end
        else
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
        local account session key cache elevated
        account=$(aws-profile list | fzf --prompt="AWS account: " --height=~40%) || return
        session=$(aws configure get sso_session --profile "$account" 2>/dev/null)
        [ -z "$session" ] && session=$(aws configure get sso_start_url --profile "$account" 2>/dev/null)
        if [ -n "$session" ]; then
          key=$(printf "%s" "$session" | shasum -a 1 | awk '{print }')
          cache="$HOME/.aws/sso/cache/$key.json"
          if [ ! -f "$cache" ] || ! python3 -c "import json,sys,datetime as dt; d=json.load(open(sys.argv[1])); e=dt.datetime.fromisoformat(d['expiresAt'].replace('Z','+00:00')); sys.exit(0 if e>dt.datetime.now(dt.timezone.utc) else 1)" "$cache" 2>/dev/null; then
            aws sso login --profile "$account"
          fi
        else
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
