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
      url "https://github.com/tontinton/maki/releases/download/v0.7.4/maki-v0.7.4-aarch64-apple-darwin.tar.gz"
      sha256 "d8e7bb9454225527fe48ed3f363f39d6a7603bfbdc6724aba303fa79d110a7bf"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.7.4/maki-v0.7.4-x86_64-apple-darwin.tar.gz"
      sha256 "1d1a28dcc90ffce5a49cda498f6e73942768d58f01300ff319b664a08a29eebf"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.7.4/maki-v0.7.4-aarch64-unknown-linux-musl.tar.gz"
      sha256 "2d580234b2835e72690900340d95b274bd2448b7ebfdadfb71f99b828e9edec4"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.7.4/maki-v0.7.4-x86_64-unknown-linux-musl.tar.gz"
      sha256 "25b93f56bb3506fa893477effc590bed79f79fadbf4759d0256ce0c6a8d673b9"
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
