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
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.16/fx-macos-aarch64.tar.gz"
      sha256 "2158a8d42e77457a774400d225d9802bb6c0e60a0bb0674a1116bc31252490d6"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.16/fx-macos-x86_64.tar.gz"
      sha256 "b287974f97a0879f50b4439c46537fcd44b83326c11a230d87f596073f8d8d9b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.16/fx-linux-aarch64.tar.gz"
      sha256 "ca9441b104357e2105039dbfd4c2eaf0d6ee65a84085f23f51e880c95cbf46af"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.16/fx-linux-x86_64.tar.gz"
      sha256 "f0fb822c7be546c80bcc89d50521bc1454435e0c6f586e8420c4e2b84fa80599"
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
