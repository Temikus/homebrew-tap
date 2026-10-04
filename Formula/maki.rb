class Maki < Formula
  desc "AI coding agent for the terminal, extendable by neovim-like Lua plugins"
  homepage "https://maki.sh"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.6.0/maki-v0.6.0-aarch64-apple-darwin.tar.gz"
      sha256 "654f5f05e71d28fa50e3af287117a5c2ca55f8b84cde972c7aa1cb732817b1e4"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.6.0/maki-v0.6.0-x86_64-apple-darwin.tar.gz"
      sha256 "2a683575060db9dc2cd68c243184f6732943ca1bd8e00279f8756e2f5dfbc23f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.6.0/maki-v0.6.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "3e57e05e0e81463c0e2e3ddc9b5f4325a493c0caad8420e7589383468cc83809"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.6.0/maki-v0.6.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "4fbdbb84ec0e07977453a25680752b4c75b0408f03550a71f15021c3881e965c"
    end
  end

  def install
    bin.install "maki"
  end

  # `maki update` self-updates in place, which would desync Homebrew's records.
  def caveats
    <<~EOS
      Use `brew upgrade maki` rather than `maki update` to keep Homebrew in sync.
    EOS
  end

  test do
    assert_match "maki #{version}", shell_output("#{bin}/maki --version")
    assert_match "AI coding agent for the terminal", shell_output("#{bin}/maki --help")
  end
end
