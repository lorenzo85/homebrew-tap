class AwsProfile < Formula
  desc "AWS IAM Identity Center profile switcher for infrastructure operators"
  homepage "https://github.com/lorenzo85/aws-profile"
  version "0.9.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.1/aws-profile-darwin-arm64.tar.gz"
      sha256 "9129693150601f80551c912f5b2586aafb798843c483193874db6452e60a62f1"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.1/aws-profile-darwin-amd64.tar.gz"
      sha256 "5d9d680f500a5a3700914ffd445509ae75561be772389992c087d573e12634da"
    end
  end

  depends_on "fzf"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.1/aws-profile-linux-arm64.tar.gz"
      sha256 "fb896559be0784a1596db2f7339d03f2e86a4964c1b2506fc57b135ad88e2255"
    else
      url "https://github.com/lorenzo85/aws-profile/releases/download/v0.9.1/aws-profile-linux-amd64.tar.gz"
      sha256 "89d740b5b32d0c447367f3d4a3a99737eed73d38f680d5ced1eb7ea5817cc70f"
    end
  end

  def install
    bin.install "aws-profile"

    # Fish function
    (share/"fish/vendor_functions.d").mkpath
    (share/"fish/vendor_functions.d/awsp.fish").write <<~FISH
      function awsp --description 'Interactively select an AWS profile'
        set accounts (aws-profile list | fzf --prompt="AWS account: " --height=~40% --multi --bind 'space:toggle' --marker '✓ ')
        test -n "$accounts" || return
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
        accounts=$(aws-profile list | fzf --prompt="AWS account: " --height=~40% --multi --bind 'space:toggle' --marker '✓ ') || return
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
