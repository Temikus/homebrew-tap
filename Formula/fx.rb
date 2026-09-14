class Fx < Formula
  desc "Tiny, open, embeddable, native coding agent"
  homepage "https://github.com/vercel-labs/fx"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.7/fx-macos-aarch64.tar.gz"
      sha256 "497cbabc50c57ecf81f8affe042a07d930c0418868e767b28afada4bddd05748"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.7/fx-macos-x86_64.tar.gz"
      sha256 "c457e4ef41fbcfcb67718ba07a21f5e00418295127f99980ea8ce38d955dd546"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.7/fx-linux-aarch64.tar.gz"
      sha256 "4a3fb1b0114b8a4f933de64f85fb2288095c17631a0c3ca897aa05601d049974"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.7/fx-linux-x86_64.tar.gz"
      sha256 "c5787ea041d3b5521ec675f1ada78f30cf1b11021ffcac48b4969cf5beb65c45"
    end
  end

  def install
    bin.install "fx"
    prefix.install "LICENSE", "THIRD_PARTY_NOTICES.md"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/fx --version").strip
    assert_match "coding agent", shell_output("#{bin}/fx --help")
  end
end
