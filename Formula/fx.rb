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
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.11/fx-macos-aarch64.tar.gz"
      sha256 "b8fe13452673a26ff474dcdbe79925bdeb5a8582fcb0db89d06502f2e250945a"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.11/fx-macos-x86_64.tar.gz"
      sha256 "8f13c5e6d3d977ea1313fc1ae54d96d42e3c5847bbdc99998b99023b08bf183e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.11/fx-linux-aarch64.tar.gz"
      sha256 "0067d2156ac31956f52bb0b7b69722733d2756a373f47c4456681b1490b458fe"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.11/fx-linux-x86_64.tar.gz"
      sha256 "0438a067df1e2b0e2d85f1e018795b7fe5a4b5fafb37f4a590a733917e53943b"
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
