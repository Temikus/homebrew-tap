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
      url "https://github.com/tontinton/maki/releases/download/v0.6.1/maki-v0.6.1-aarch64-apple-darwin.tar.gz"
      sha256 "ed9262715d88ea585814b97bda123274d830e8571b27bfd03c6d29760e274da6"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.6.1/maki-v0.6.1-x86_64-apple-darwin.tar.gz"
      sha256 "fa33cda6126449833e49f04d5a07e88b2bbd0e711d1d0b87fb467cc17ab2f251"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.6.1/maki-v0.6.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "4295ddda28823442df67c4afd6e475fbd74078474fec06b95b912e7c0a68dd2a"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.6.1/maki-v0.6.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "dc7658c1745a13b042a8a1bce146c96588d6a2d8cf3686a6dea17e7bf013fb5d"
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
