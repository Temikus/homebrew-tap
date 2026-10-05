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
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.13/fx-macos-aarch64.tar.gz"
      sha256 "9dbed465d6c56e09a399576c98bfc804a67d1c2a24dfaef896a762565592f96e"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.13/fx-macos-x86_64.tar.gz"
      sha256 "e7a93304ff2b5985ec3bdf8c05ca1ca67810c49333528a03d24114c0f6e97f24"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.13/fx-linux-aarch64.tar.gz"
      sha256 "78f6a8171193a1d2033f93d1b5a2940ea4a62147daf60a37ae670a9bf85f12e9"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.13/fx-linux-x86_64.tar.gz"
      sha256 "53a3b30ce1541048f8fa4b42b7bc68161466bb2e3708db104449a58af3807430"
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
