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
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.10/fx-macos-aarch64.tar.gz"
      sha256 "b3f0121e46f8227690def72b920d9d1fc299f0b73dd7eb91382bd83674219876"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.10/fx-macos-x86_64.tar.gz"
      sha256 "0dd01badf66d1b8a0fe538e9fd5e42b3b4dcafd6aa9327ee9b9611a3d01d6e18"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.10/fx-linux-aarch64.tar.gz"
      sha256 "27134fadb97e98e5c847070f96c211da1b2bfc9babf5573baa7537282362fbd8"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.10/fx-linux-x86_64.tar.gz"
      sha256 "45bf4d88e786f549039a10ce1402831b9937e716956a6ef905a0d3cbe6bd97af"
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
