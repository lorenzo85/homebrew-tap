class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.9.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.3/aws-profile-darwin-arm64.tar.gz"
      sha256 "25b09ad7592778b77dfe4d0780c1941bec8b3a34ef8919ef4c2fde7204f3091b"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.3/aws-profile-darwin-amd64.tar.gz"
      sha256 "269d9e602e23105a030e66a8451d1701637b4e6b78588e53148736e356484b19"
    end
  end

  depends_on "fzf"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.3/aws-profile-linux-arm64.tar.gz"
      sha256 "09a884db6d1cf5d93bbd08734a82e1d00b16e6ca477407af8b62be4b364ac122"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.3/aws-profile-linux-amd64.tar.gz"
      sha256 "96b2ff1ae56cd80436b80c0722631194a609307d87070c9a8c48807a0bccb279"
    end
  end

  def install
    bin.install "aws-profile"

    # Fish function
    (share/"fish/vendor_functions.d").mkpath
    (share/"fish/vendor_functions.d/awsp.fish").write <<~FISH
      function awsp --description 'Interactively select an AWS profile'
        set selection (begin; echo "[all > standing access]"; aws-profile list; end | fzf --prompt="AWS account: " --height=~40% --multi --bind 'space:toggle' --marker '✓ ')
        test -n "$selection" || return
        if contains -- "[all > standing access]" $selection
          aws-profile reset
          return
        end
        set accounts $selection
        set start_url (aws configure get sso_start_url --profile $accounts[1] 2>/dev/null)
        if not python3 -c "import json,glob,os,sys; from datetime import datetime,timezone; m=next((d for f in glob.glob(os.path.expanduser('~/.aws/sso/cache/*.json')) for d in [json.load(open(f))] if d.get('startUrl')==sys.argv[1] and d.get('accessToken')),None); sys.exit(0 if m and datetime.fromisoformat(m['expiresAt'].replace('Z','+00:00'))>datetime.now(timezone.utc) else 1)" $start_url 2>/dev/null
          aws sso login --profile $accounts[1]
        end
        read -l -P "Elevated access? [y/N] " elevated
        for account in $accounts
          if test "$elevated" = y -o "$elevated" = Y
            aws-profile $account+
          else
            aws-profile $account
          end
        end
      end
    FISH

    # Zsh/Bash function
    (share/"zsh/site-functions").mkpath
    (share/"zsh/site-functions/_awsp").write <<~ZSH
      awsp() {
        local accounts start_url elevated account
        accounts=$({ echo "[all > standing access]"; aws-profile list; } | fzf --prompt="AWS account: " --height=~40% --multi --bind 'space:toggle' --marker '✓ ') || return
        if echo "$accounts" | grep -qx '\[all → standing access\]'; then
          aws-profile reset
          return
        fi
        start_url=$(aws configure get sso_start_url --profile "$(echo "$accounts" | head -1)" 2>/dev/null)
        if ! python3 -c "import json,glob,os,sys; from datetime import datetime,timezone; m=next((d for f in glob.glob(os.path.expanduser('~/.aws/sso/cache/*.json')) for d in [json.load(open(f))] if d.get('startUrl')==sys.argv[1] and d.get('accessToken')),None); sys.exit(0 if m and datetime.fromisoformat(m['expiresAt'].replace('Z','+00:00'))>datetime.now(timezone.utc) else 1)" "$start_url" 2>/dev/null; then
          aws sso login --profile "$(echo "$accounts" | head -1)"
        fi
        read "elevated?Elevated access? [y/N] "
        while IFS= read -r account; do
          if [[ "$elevated" =~ ^[Yy]$ ]]; then
            aws-profile "${account}+"
          else
            aws-profile "$account"
          fi
        done <<< "$accounts"
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
