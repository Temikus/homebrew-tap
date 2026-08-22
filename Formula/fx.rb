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
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.5/fx-macos-aarch64.tar.gz"
      sha256 "2b98cc1a85c1cf5ea213f1df71cca79f7cbff65793d2a87282c04ca019cbd1c1"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.5/fx-macos-x86_64.tar.gz"
      sha256 "0da4a90034c1afcd251a1a2cb237ea3a0013c965ad8c2a45b7713694b530ad8a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.5/fx-linux-aarch64.tar.gz"
      sha256 "8bbcde6a41256c4fac4e0a022291cf02740419e27afabde3b8f45e7a4e393edb"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.5/fx-linux-x86_64.tar.gz"
      sha256 "d5639d173267774aa8228a474baf619a7076ac41a91023915007c865143429b1"
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
