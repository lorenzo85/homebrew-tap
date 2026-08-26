class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.9.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.2/aws-profile-darwin-arm64.tar.gz"
      sha256 "e753d66afc0eecb9c91f1328e5823a5f52bddaa37f3fb8cc862bcd75bc030d6d"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.2/aws-profile-darwin-amd64.tar.gz"
      sha256 "0fc8e4a258bc8fe6e11a5e8ca3ff33438abc785ead74fc9b377fada9b2b0007b"
    end
  end

  depends_on "fzf"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.2/aws-profile-linux-arm64.tar.gz"
      sha256 "21581b41bb4cb18506dd8ad56f4362eb274078213614529653cab81f97b8454d"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.2/aws-profile-linux-amd64.tar.gz"
      sha256 "39569ee32ea5def13e6382028ab7be1a5dffe94057c4bfc6caa4ef4c73d847e4"
    end
  end

  def install
    bin.install "aws-profile"

    # Fish function
    (share/"fish/vendor_functions.d").mkpath
    (share/"fish/vendor_functions.d/awsp.fish").write <<~FISH
      function awsp --description 'Interactively select an AWS profile'
        set selection (begin; echo "[all → standing access]"; aws-profile list; end | fzf --prompt="AWS account: " --height=~40% --multi --bind 'space:toggle' --marker '✓ ')
        test -n "$selection" || return
        if contains -- "[all → standing access]" $selection
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
        accounts=$({ echo "[all → standing access]"; aws-profile list; } | fzf --prompt="AWS account: " --height=~40% --multi --bind 'space:toggle' --marker '✓ ') || return
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
