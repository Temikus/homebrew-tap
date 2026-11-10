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
      url "https://github.com/tontinton/maki/releases/download/v0.7.1/maki-v0.7.1-aarch64-apple-darwin.tar.gz"
      sha256 "60561c7c84faa015c2694b47064cd927dfdd244f6ee5909a83e337516daea1c9"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.7.1/maki-v0.7.1-x86_64-apple-darwin.tar.gz"
      sha256 "cee8f8ce0640284eec11c2a4d3805286201e0c7729737ae9459d31c7cded92d2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.7.1/maki-v0.7.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "833efa48ea018f0ee40e1df74b18b0d14313b0946be8bdc759e1cd098bbb8f0a"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.7.1/maki-v0.7.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d2114bc73a702fc85dc6d158166630a8a220b74d91239441bec258138af9cb9a"
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
