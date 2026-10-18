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
      url "https://github.com/tontinton/maki/releases/download/v0.6.4/maki-v0.6.4-aarch64-apple-darwin.tar.gz"
      sha256 "2122bf3909c44ead288d0aa9dc879eb14731d3cdda5889ccf03bf9a369f90d2c"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.6.4/maki-v0.6.4-x86_64-apple-darwin.tar.gz"
      sha256 "44966c2b0e30bafb9d71f1673924513108d454e412e3430af39c9fec668fd5a7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.6.4/maki-v0.6.4-aarch64-unknown-linux-musl.tar.gz"
      sha256 "cf1bd089acfd24191a99abf93e37e12081bfea1745db6c4094ad3ec3dd74921f"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.6.4/maki-v0.6.4-x86_64-unknown-linux-musl.tar.gz"
      sha256 "1c02315bb5aa59f1fabbf15734e9a8c234e9ea6083f2788b769347f7bd94e87a"
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
