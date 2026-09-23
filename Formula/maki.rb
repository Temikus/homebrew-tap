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
      url "https://github.com/tontinton/maki/releases/download/v0.5.6/maki-v0.5.6-aarch64-apple-darwin.tar.gz"
      sha256 "8fa14b65c88f9d1c02909353b6b76ca55aa1c89fcb5a3191afa23e6aea6bad57"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.5.6/maki-v0.5.6-x86_64-apple-darwin.tar.gz"
      sha256 "c2c8218594ec670c021d1d6d723fe478cebd4f7c1e4c17e323f0277fd8958301"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.5.6/maki-v0.5.6-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ab59b9099af394273d892a9da92ae7f09495dd2314ebf1fca968ea60fbde3751"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.5.6/maki-v0.5.6-x86_64-unknown-linux-musl.tar.gz"
      sha256 "4864b79237c70b8292f120c1b17a52cdaca7a7af3db0baed2c2da3dae41d7dcd"
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
