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
      url "https://github.com/tontinton/maki/releases/download/v0.4.11/maki-v0.4.11-aarch64-apple-darwin.tar.gz"
      sha256 "fd35bc1c408eebe871428c6f08b77e1135de7f1e12aa65798bf91687479b5eda"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.4.11/maki-v0.4.11-x86_64-apple-darwin.tar.gz"
      sha256 "26fb21b587cbb3c18669c2506c7b4c84fbd007bb5b9281a3816e378c1a1a31f1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.4.11/maki-v0.4.11-aarch64-unknown-linux-musl.tar.gz"
      sha256 "f3a7468983934a1d22c634b7db54357211f3dc72e45e52c2a217c8bdd89fe391"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.4.11/maki-v0.4.11-x86_64-unknown-linux-musl.tar.gz"
      sha256 "96f8b8cdc3044d1d6b739f77da8e5b5240493e9c525f4a5754a8a135c75b182c"
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
