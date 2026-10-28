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
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.15/fx-macos-aarch64.tar.gz"
      sha256 "9f7dcae1f42080d8a668ff8fec172d90d071a52540255776479bf973bc5a349b"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.15/fx-macos-x86_64.tar.gz"
      sha256 "dfa5199908150c19a9c8adc90f72bccefbe17d6740eddd0240f3b943ccdaf610"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.15/fx-linux-aarch64.tar.gz"
      sha256 "1c06e770aa87e39c6a4807d6a42fc5508d051e4a381fb2c35e0728fc1f41d461"
    end
    on_intel do
      url "https://github.com/vercel-labs/fx/releases/download/v0.0.15/fx-linux-x86_64.tar.gz"
      sha256 "52def957321dc482c635ed613a4fff3489202b0374b6ccc6dc823e65736bbf26"
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
