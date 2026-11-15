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
      url "https://github.com/tontinton/maki/releases/download/v0.7.2/maki-v0.7.2-aarch64-apple-darwin.tar.gz"
      sha256 "de286c993de103ce85d0be08681e7baad57731fe094874273c3972749c7820d4"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.7.2/maki-v0.7.2-x86_64-apple-darwin.tar.gz"
      sha256 "805fdd641b00798c94db7c4a6bf1f1bfaa60802d533da5683d391585eddb4759"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.7.2/maki-v0.7.2-aarch64-unknown-linux-musl.tar.gz"
      sha256 "f59aa1a0c90c67ff045de96be5f197c915704b4bb77b48b04259f1f80f7f6429"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.7.2/maki-v0.7.2-x86_64-unknown-linux-musl.tar.gz"
      sha256 "8b45124b74d1697a95948c51cd86eea20a7e8ab3989b478eedd1a4844b08a93c"
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
