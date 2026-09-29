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
      url "https://github.com/tontinton/maki/releases/download/v0.5.7/maki-v0.5.7-aarch64-apple-darwin.tar.gz"
      sha256 "f84725c29a34412d920879a24872202f8c0d679f7d28fbe41471ad18e1543523"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.5.7/maki-v0.5.7-x86_64-apple-darwin.tar.gz"
      sha256 "caf4dbd33fbb3dca482a5bfb5f96afb56f77e17108077a0dc7061f2e96225b9f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.5.7/maki-v0.5.7-aarch64-unknown-linux-musl.tar.gz"
      sha256 "083ec21f06d8f9d99fa7f3607346044df2212926140285fb9e2bfb2d1a370f40"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.5.7/maki-v0.5.7-x86_64-unknown-linux-musl.tar.gz"
      sha256 "ab418e7b75f79de88b05f8b0bef8f89b5e3fa93745af9b88b6daae007a9c3bf2"
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
