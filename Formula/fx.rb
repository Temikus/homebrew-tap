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
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.18/fx-macos-aarch64.tar.gz"
      sha256 "f37eea7eaf248f7a75765fc3f71be77bcfbc43eaef5cbe76d721dadb97479cfe"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.18/fx-macos-x86_64.tar.gz"
      sha256 "becc6f68d42ff20606cd783b72630287ab92bc6eef2d700ed39de17d52b7dd3e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.18/fx-linux-aarch64.tar.gz"
      sha256 "432a343b7d0fb15dce454ab1e100401df1ee4f01fb1e689a64557e6b9a57ece5"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.18/fx-linux-x86_64.tar.gz"
      sha256 "e4912040c1fb2a1cda4162fd8f40fc66aa80a1a0a306af6332b5426bdcac99b6"
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
