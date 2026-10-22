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
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.14/fx-macos-aarch64.tar.gz"
      sha256 "619c6dccf4e8cd6290ec4a052d29c8724b2a4b150d893435b3de9086c21fb7b1"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.14/fx-macos-x86_64.tar.gz"
      sha256 "6735101f94b1213278ade6109988f172493b863e8060b5152903d21467b95213"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.14/fx-linux-aarch64.tar.gz"
      sha256 "9f5cfbac1728fffddc2d5d874d1f7fe8d34f179e1bc86fb2e67a6e75074e53f3"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.14/fx-linux-x86_64.tar.gz"
      sha256 "731c1914fc2d497a10583f4416f8382c192e4897d6a0b4f713d6194455a8548b"
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
