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
      url "https://github.com/tontinton/maki/releases/download/v0.5.4/maki-v0.5.4-aarch64-apple-darwin.tar.gz"
      sha256 "662f851a2342204892a32cfecde95590d2b88e24e26ee5775cd850532996250a"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.5.4/maki-v0.5.4-x86_64-apple-darwin.tar.gz"
      sha256 "7d220a914a914aa301070665f274418a0dfb4ad7ee22434e3494c989851e7ef0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.5.4/maki-v0.5.4-aarch64-unknown-linux-musl.tar.gz"
      sha256 "b0e915ab6429b034565fd985642b98484347ccab175e69b2600ee7492348e65d"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.5.4/maki-v0.5.4-x86_64-unknown-linux-musl.tar.gz"
      sha256 "8314bb716ad68effa041b0703e44a74441e8fe946acb6f78d864cedb77489d0f"
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
