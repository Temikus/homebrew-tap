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
      url "https://github.com/tontinton/maki/releases/download/v0.7.3/maki-v0.7.3-aarch64-apple-darwin.tar.gz"
      sha256 "f336adffaf16eb9d51620368fe41c9f776e418ddb48bcf4727e75a1ecbf77afa"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.7.3/maki-v0.7.3-x86_64-apple-darwin.tar.gz"
      sha256 "ba6bf9f71b4914419e0e05a32fd738fa01a325d02a4f49dcc0486eefe1295c4c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.7.3/maki-v0.7.3-aarch64-unknown-linux-musl.tar.gz"
      sha256 "15ffb3e67489fd18cc1c289826ae9255d2b5911bbbc09d2c76c9c7b93c87606d"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.7.3/maki-v0.7.3-x86_64-unknown-linux-musl.tar.gz"
      sha256 "89948bd1834d659abfd7f3e5947d71abe46e5b11e061e495555e174f6a7c564e"
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
