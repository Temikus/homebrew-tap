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
      url "https://github.com/tontinton/maki/releases/download/v0.7.0/maki-v0.7.0-aarch64-apple-darwin.tar.gz"
      sha256 "cf994a0d2ac64b5f6b38be9410602ebd2710a7924148d416ef623df41d6f7a67"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.7.0/maki-v0.7.0-x86_64-apple-darwin.tar.gz"
      sha256 "ec5a3964845f0663de268021568e7fb8b591d122d55dbeb1e559b69f43e8c904"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tontinton/maki/releases/download/v0.7.0/maki-v0.7.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "7b4ee654b0df45077df676360462754fb9d1c4dca0a7662f68f05ee825936546"
    end
    on_intel do
      url "https://github.com/tontinton/maki/releases/download/v0.7.0/maki-v0.7.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "3e0a1d1a4bc2bbaafdeb94f2a551bcc2d0f6ed81edfd9dd13272d9caa5add787"
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
