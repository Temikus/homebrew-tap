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
      url "https://github.com/tontinton/maki/releases/download/v0.6.3/maki-v0.6.3-aarch64-apple-darwin.tar.gz"
      sha256 "ebf4b163cb3df95c775c713d2c03b49fc371cff19c81d183c11ed48ee91fcc60"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.6.3/maki-v0.6.3-x86_64-apple-darwin.tar.gz"
      sha256 "f6ae22741a46cbdad16672cc3ba0376b2b1c725a5e3b36fe6ab6840a48de5737"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.6.3/maki-v0.6.3-aarch64-unknown-linux-musl.tar.gz"
      sha256 "215ebf086d30999c78301abe03c970fb860b2f25a0baf64b19c3c89c4d565f7d"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.6.3/maki-v0.6.3-x86_64-unknown-linux-musl.tar.gz"
      sha256 "55c81674e9671d03aacc984af26bb63b9c33721b26521d5c1fe44bcb09aab0e4"
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
