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
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.12/fx-macos-aarch64.tar.gz"
      sha256 "c59dae590fd1244af5f02d3bfaf86a83f9d738e1f3dfb8d0bfab7ff15fb8ce20"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.12/fx-macos-x86_64.tar.gz"
      sha256 "bca035a0ff0239e983e12b0131f6962bbe3b85ad86576a10297eb8bf1000d7ef"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.12/fx-linux-aarch64.tar.gz"
      sha256 "7265ecebf881ec4050d24fa4fac660ed86dfd11395fcde47b491dc084be1e61e"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.12/fx-linux-x86_64.tar.gz"
      sha256 "c510956b92404a00f3054b4be0d378188f9f5217497555048de353b8f0e52d80"
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
