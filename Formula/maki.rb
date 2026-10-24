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
      url "https://github.com/tontinton/maki/releases/download/v0.6.5/maki-v0.6.5-aarch64-apple-darwin.tar.gz"
      sha256 "678fe77bb6c202f477a9f7897ed55b27bc71187d2da7edf428775f6a401ae7b8"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.6.5/maki-v0.6.5-x86_64-apple-darwin.tar.gz"
      sha256 "e00068a885a7012dd7d03f3c1fe4794bf5699672b8fad229a75115cae6e43c31"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.6.5/maki-v0.6.5-aarch64-unknown-linux-musl.tar.gz"
      sha256 "457c8a1ae1ca5174f69abebc4169823bc8bdc96232c4fe4d88d51a6e60e1a263"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.6.5/maki-v0.6.5-x86_64-unknown-linux-musl.tar.gz"
      sha256 "a8c5311a292201c728354add3aa27ed32d0ffd374f4f9d136ba3a92949fb5352"
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
